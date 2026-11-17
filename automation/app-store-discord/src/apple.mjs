const API_ORIGIN = 'https://api.appstoreconnect.apple.com';
const DAY_MS = 86_400_000;
const MAX_PAGES = 40;
const MAX_ITEMS = 10_000;
const MAX_SEGMENTS = 200;
const MAX_JSON_BYTES = 4 * 1024 * 1024;
const MAX_COMPRESSED_BYTES = 20 * 1024 * 1024;
const MAX_EXPANDED_BYTES = 50 * 1024 * 1024;
const MAX_FETCHES = 40;

export class AppleReportError extends Error {
  constructor(code, message) {
    super(message);
    this.name = 'AppleReportError';
    this.code = code;
  }
}

function fail(code, message) {
  throw new AppleReportError(code, message);
}

function required(env, name) {
  const value = env[name];
  if (typeof value !== 'string' || !value.trim()) {
    fail('CONFIGURATION', `${name} is required.`);
  }
  return value.trim();
}

function base64url(bytes) {
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll('+', '-').replaceAll('/', '_').replace(/=+$/, '');
}

function encodedJSON(value) {
  return base64url(new TextEncoder().encode(JSON.stringify(value)));
}

export async function createAppleJWT(env, { now = new Date() } = {}) {
  const keyId = required(env, 'ASC_KEY_ID');
  const issuerId = required(env, 'ASC_ISSUER_ID');
  const pem = required(env, 'ASC_PRIVATE_KEY').replaceAll('\\n', '\n');
  if (!Number.isFinite(now.getTime())) fail('CONFIGURATION', 'Invalid current time.');
  try {
    const match = pem.match(/^-----BEGIN PRIVATE KEY-----\s+([A-Za-z0-9+/=\s]+)\s+-----END PRIVATE KEY-----$/);
    if (!match) fail('CONFIGURATION', 'ASC_PRIVATE_KEY must be a PKCS#8 PEM private key.');
    const binary = atob(match[1].replace(/\s/g, ''));
    const bytes = Uint8Array.from(binary, (character) => character.charCodeAt(0));
    const key = await crypto.subtle.importKey('pkcs8', bytes, { name: 'ECDSA', namedCurve: 'P-256' }, false, ['sign']);
    const issuedAt = Math.floor(now.getTime() / 1000);
    const unsigned = `${encodedJSON({ alg: 'ES256', kid: keyId, typ: 'JWT' })}.${encodedJSON({ iss: issuerId, iat: issuedAt, exp: issuedAt + 900, aud: 'appstoreconnect-v1' })}`;
    const signature = await crypto.subtle.sign({ name: 'ECDSA', hash: 'SHA-256' }, key, new TextEncoder().encode(unsigned));
    return `${unsigned}.${base64url(new Uint8Array(signature))}`;
  } catch (error) {
    if (error instanceof AppleReportError) throw error;
    fail('CONFIGURATION', 'Unable to sign the App Store Connect token. Check the API key configuration.');
  }
}

function isDate(value) {
  return typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value)
    && Number.isFinite(Date.parse(`${value}T00:00:00Z`))
    && new Date(`${value}T00:00:00Z`).toISOString().slice(0, 10) === value;
}

function shiftDate(value, offset) {
  return new Date(Date.parse(`${value}T00:00:00Z`) + offset * DAY_MS).toISOString().slice(0, 10);
}

function resourceId(value) {
  if (typeof value !== 'string' || !value || value.length > 256) fail('SCHEMA', 'Apple returned an invalid resource identifier.');
  return encodeURIComponent(value);
}

function apiURL(value) {
  let url;
  try { url = new URL(value, API_ORIGIN); } catch { fail('SCHEMA', 'Apple returned an invalid API URL.'); }
  if (url.origin !== API_ORIGIN || !url.pathname.startsWith('/v1/') || url.username || url.password || url.hash) {
    fail('UNSAFE_URL', 'Apple returned an unexpected API URL.');
  }
  return url.toString();
}

function downloadURL(value) {
  let url;
  try { url = new URL(value); } catch { fail('SCHEMA', 'Apple returned an invalid report URL.'); }
  const trustedHost = url.hostname.endsWith('.apple.com') || url.hostname.endsWith('.amazonaws.com');
  if (url.protocol !== 'https:' || !trustedHost || url.username || url.password || url.port || url.hash) {
    fail('UNSAFE_URL', 'Apple returned an unexpected report download host.');
  }
  return url.toString();
}

async function boundedBytes(body, maximum) {
  if (!body) fail('SCHEMA', 'Apple returned an empty response body.');
  const reader = body.getReader();
  const chunks = [];
  let total = 0;
  try {
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      total += value.byteLength;
      if (total > maximum) {
        await reader.cancel();
        fail('LIMIT', 'The report exceeds the configured processing size limit.');
      }
      chunks.push(value);
    }
  } finally {
    reader.releaseLock();
  }
  const output = new Uint8Array(total);
  let offset = 0;
  for (const chunk of chunks) {
    output.set(chunk, offset);
    offset += chunk.byteLength;
  }
  return output;
}

function parseTSV(text) {
  const rows = [];
  let row = [];
  let field = '';
  let quoted = false;
  let closedQuote = false;
  const source = text.replace(/^\uFEFF/, '');
  const endField = () => { row.push(field); field = ''; closedQuote = false; };
  const endRow = () => {
    endField();
    if (row.some((value) => value !== '')) rows.push(row);
    row = [];
    if (rows.length > 500_000) fail('LIMIT', 'The report contains too many rows.');
  };
  for (let index = 0; index < source.length; index += 1) {
    const character = source[index];
    if (quoted) {
      if (character === '"' && source[index + 1] === '"') { field += '"'; index += 1; }
      else if (character === '"') { quoted = false; closedQuote = true; }
      else field += character;
    } else if (character === '\t') endField();
    else if (character === '\n' || character === '\r') {
      if (character === '\r' && source[index + 1] === '\n') index += 1;
      endRow();
    } else if (character === '"' && !field && !closedQuote) quoted = true;
    else {
      if (closedQuote || character === '"') fail('SCHEMA', 'The report contains malformed TSV quoting.');
      field += character;
    }
  }
  if (quoted) fail('SCHEMA', 'The report contains unterminated TSV quoting.');
  if (field || row.length || closedQuote) endRow();
  return rows;
}

function accumulate(text, appId, processingDate, totals, oldestDate) {
  const [header, ...rows] = parseTSV(text);
  if (!header || new Set(header).size !== header.length) fail('SCHEMA', 'The report has missing or duplicate columns.');
  const columns = ['Date', 'App Apple Identifier', 'Download Type', 'Counts'].map((name) => header.indexOf(name));
  if (columns.some((index) => index < 0)) fail('SCHEMA', 'The report is missing required download columns.');
  for (const row of rows) {
    if (row.length !== header.length) fail('SCHEMA', 'The report contains a malformed row.');
    const [date, rowAppId, type, rawCount] = columns.map((index) => row[index].trim());
    if (rowAppId !== appId) continue;
    if (!isDate(date) || date > processingDate || !type || !/^\d+$/.test(rawCount)) fail('SCHEMA', 'The report contains invalid download values.');
    const count = Number(rawCount);
    if (!Number.isSafeInteger(count)) fail('SCHEMA', 'The report contains an invalid download count.');
    if (date < oldestDate) continue;
    // A date with only other download types is a known zero. An absent date stays unknown.
    const previous = totals.get(date) ?? 0;
    const next = previous + (type.toLowerCase().replace(/\s+/g, ' ') === 'first-time download' ? count : 0);
    if (!Number.isSafeInteger(next)) fail('SCHEMA', 'The download total exceeds the supported range.');
    totals.set(date, next);
  }
}

/** Read existing ONGOING reports. This function never creates report requests or mutates previous. */
export async function collectDownloads(env, previous = { days: {} }, { fetchImpl = fetch, now = new Date() } = {}) {
  const appId = required(env, 'ASC_APP_ID');
  if (!/^\d+$/.test(appId)) fail('CONFIGURATION', 'ASC_APP_ID must be a numeric Apple app ID.');
  if (!Number.isFinite(now.getTime())) fail('CONFIGURATION', 'Invalid current time.');
  if (previous.appId && previous.appId !== appId) fail('CACHE_APP_MISMATCH', 'The saved report belongs to a different app.');
  const today = now.toISOString().slice(0, 10);
  if (previous.startDate != null && (!isDate(previous.startDate) || previous.startDate > today)) {
    fail('CACHE_SCHEMA', 'The saved history start date is invalid.');
  }
  // Lifetime history must survive Apple's 35-day instance retention, including old corrections.
  const oldestDate = previous.startDate ?? shiftDate(today, -89);
  const earliestProcessingDate = shiftDate(today, -34);
  const days = {};
  if (!previous.days || typeof previous.days !== 'object' || Array.isArray(previous.days)) fail('CACHE_SCHEMA', 'The saved download data is invalid.');
  for (const [date, value] of Object.entries(previous.days)) {
    if (!isDate(date) || !value || !Number.isSafeInteger(value.count) || value.count < 0 || !isDate(value.processingDate) || value.processingDate < date) {
      fail('CACHE_SCHEMA', 'The saved download data is invalid.');
    }
    if (date >= oldestDate && date <= today) days[date] = { count: value.count, processingDate: value.processingDate };
  }
  const token = await createAppleJWT(env, { now });
  const maxInstances = Number(env.ASC_MAX_INSTANCES_PER_SYNC ?? 12);
  if (!Number.isInteger(maxInstances) || maxInstances < 1 || maxInstances > 20) fail('CONFIGURATION', 'ASC_MAX_INSTANCES_PER_SYNC must be an integer from 1 to 20.');
  let requestCount = 0;
  let downloadedSegments = 0;
  let expandedBytes = 0;

  async function request(url, appleAPI) {
    if (requestCount >= MAX_FETCHES) fail('FETCH_BUDGET', 'The current report sync reached its request budget.');
    requestCount += 1;
    try {
      const response = await fetchImpl(url, {
        headers: appleAPI ? { Authorization: `Bearer ${token}`, Accept: 'application/json' } : {},
        redirect: 'error',
        signal: AbortSignal.timeout(10_000),
      });
      if (!response.ok) fail('HTTP', `${appleAPI ? 'Apple API' : 'Report download'} failed (HTTP ${response.status}).`);
      return response;
    } catch (error) {
      if (error instanceof AppleReportError) throw error;
      fail('NETWORK', `${appleAPI ? 'Apple API' : 'Report download'} could not be completed. Retry later.`);
    }
  }

  async function list(path) {
    let next = apiURL(path);
    const visited = new Set();
    const items = new Map();
    while (next) {
      if (visited.has(next)) fail('PAGINATION', 'Apple returned a pagination cycle.');
      if (visited.size >= MAX_PAGES) fail('LIMIT', 'Apple returned too many report pages.');
      visited.add(next);
      const response = await request(next, true);
      let json;
      try {
        const bytes = await boundedBytes(response.body, MAX_JSON_BYTES);
        json = JSON.parse(new TextDecoder('utf-8', { fatal: true }).decode(bytes));
      } catch (error) {
        if (error instanceof AppleReportError) throw error;
        fail('SCHEMA', 'Apple returned invalid report metadata.');
      }
      if (!Array.isArray(json.data)) fail('SCHEMA', 'Apple returned an invalid resource list.');
      for (const item of json.data) {
        resourceId(item?.id);
        if (!item.attributes || typeof item.attributes !== 'object') fail('SCHEMA', 'Apple returned incomplete resource metadata.');
        const earlier = items.get(item.id);
        if (earlier && JSON.stringify(earlier.attributes) !== JSON.stringify(item.attributes)) fail('SCHEMA', 'Apple returned inconsistent duplicate resources.');
        items.set(item.id, item);
        if (items.size > MAX_ITEMS) fail('LIMIT', 'Apple returned too many report resources.');
      }
      const link = json.links?.next;
      if (link != null && typeof link !== 'string') fail('SCHEMA', 'Apple returned invalid pagination metadata.');
      next = link ? apiURL(link) : null;
    }
    return [...items.values()];
  }

  const requests = await list(`/v1/apps/${appId}/analyticsReportRequests?filter%5BaccessType%5D=ONGOING&limit=200`);
  const requestedId = typeof env.ASC_REPORT_REQUEST_ID === 'string' ? env.ASC_REPORT_REQUEST_ID.trim() : '';
  const active = requests.filter((item) => item.attributes.accessType === 'ONGOING' && item.attributes.stoppedDueToInactivity === false && (!requestedId || item.id === requestedId));
  if (active.length !== 1) fail('REPORT_REQUEST', 'A single active ONGOING report request is required. Complete the App Store Connect report setup.');
  const requestId = active[0].id;
  const reports = await list(`/v1/analyticsReportRequests/${resourceId(requestId)}/reports?limit=200`);
  const standard = reports.filter((item) => item.attributes.name === 'App Store Downloads Standard');
  if (standard.length !== 1) fail('REPORT_NOT_READY', 'The App Store Downloads Standard report is not available yet. Initial generation can take 24–48 hours.');
  const reportId = standard[0].id;
  const instances = await list(`/v1/analyticsReports/${resourceId(reportId)}/instances?filter%5Bgranularity%5D=DAILY&limit=200`);
  const recent = instances.filter((instance) => {
    const { processingDate, granularity } = instance.attributes;
    if (!isDate(processingDate) || processingDate > today || granularity !== 'DAILY') fail('SCHEMA', 'Apple returned invalid daily report metadata.');
    return processingDate >= earliestProcessingDate;
  }).sort((left, right) => right.attributes.processingDate.localeCompare(left.attributes.processingDate));
  if (previous.processedInstanceIds != null && (!Array.isArray(previous.processedInstanceIds) || previous.processedInstanceIds.some((id) => typeof id !== 'string'))) {
    fail('CACHE_SCHEMA', 'The saved processed report identifiers are invalid.');
  }
  const availableIds = new Set(recent.map((instance) => instance.id));
  const processed = new Set((previous.processedInstanceIds ?? []).filter((id) => availableIds.has(id)));
  let completedInstances = 0;

  for (const instance of recent) {
    if (processed.has(instance.id)) continue;
    if (completedInstances >= maxInstances || requestCount >= MAX_FETCHES) break;
    const processingDate = instance.attributes.processingDate;
    const totals = new Map();
    try {
      const segments = await list(`/v1/analyticsReportInstances/${resourceId(instance.id)}/segments?limit=200`);
      if (segments.length === 0) fail('REPORT_NOT_READY', 'A report instance has no downloadable segments yet. Retry later.');
      // Leave an instance entirely pending if its complete set cannot fit this run.
      if (segments.length > MAX_FETCHES - requestCount) break;
      for (const segment of segments) {
        downloadedSegments += 1;
        if (downloadedSegments > MAX_SEGMENTS) fail('LIMIT', 'The report contains too many download segments.');
        const response = await request(downloadURL(segment.attributes.url), false);
        try {
          const compressed = await boundedBytes(response.body, MAX_COMPRESSED_BYTES);
          const inflated = new Blob([compressed]).stream().pipeThrough(new DecompressionStream('gzip'));
          const bytes = await boundedBytes(inflated, MAX_EXPANDED_BYTES);
          expandedBytes += bytes.byteLength;
          if (expandedBytes > 100 * 1024 * 1024) fail('LIMIT', 'The report collection exceeds the processing size limit.');
          accumulate(new TextDecoder('utf-8', { fatal: true }).decode(bytes), appId, processingDate, totals, oldestDate);
        } catch (error) {
          if (error instanceof AppleReportError) throw error;
          fail('SCHEMA', 'A report segment could not be decompressed or decoded.');
        }
      }
    } catch (error) {
      if (error instanceof AppleReportError && error.code === 'FETCH_BUDGET') break;
      throw error;
    }
    for (const [date, count] of totals) {
      const saved = days[date];
      if (saved?.processingDate === processingDate && saved.count !== count) fail('CONFLICTING_REPORTS', 'Reports with the same processing date disagree. Retry after Apple finishes processing.');
      if (!saved || processingDate >= saved.processingDate) days[date] = { count, processingDate };
    }
    processed.add(instance.id);
    completedInstances += 1;
  }
  return {
    appId, ...(previous.startDate ? { startDate: previous.startDate } : {}),
    days, syncedAt: now.toISOString(), requestId, reportId,
    processedInstanceIds: [...processed],
    pendingInstances: recent.filter((instance) => !processed.has(instance.id)).length,
  };
}
