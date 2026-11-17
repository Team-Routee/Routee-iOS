import { createCipheriv, createDecipheriv, randomBytes } from 'node:crypto';

const MAX_BYTES = 2 * 1024 * 1024;
const PURPOSE = Buffer.from('routee-app-store-discord/download-history/v1', 'utf8');

export class HistoryError extends Error {
  constructor(code, message) {
    super(message);
    this.name = 'HistoryError';
    this.code = code;
  }
}

function fail(code, message) {
  throw new HistoryError(code, message);
}

function object(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value)
    && (Object.getPrototypeOf(value) === Object.prototype || Object.getPrototypeOf(value) === null);
}

function date(value) {
  return typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value)
    && Number.isFinite(Date.parse(`${value}T00:00:00Z`))
    && new Date(`${value}T00:00:00Z`).toISOString().slice(0, 10) === value;
}

function decode(value, size, code = 'HISTORY_DECRYPT_FAILED') {
  if (typeof value !== 'string' || !value || value.length > MAX_BYTES
      || !/^[A-Za-z0-9+/]+={0,2}$/.test(value)) {
    fail(code, '집계 이력의 암호화 설정 또는 파일을 확인해 주세요.');
  }
  const bytes = Buffer.from(value, 'base64');
  if (bytes.toString('base64') !== value || (size !== undefined && bytes.length !== size)) {
    fail(code, '집계 이력의 암호화 설정 또는 파일을 확인해 주세요.');
  }
  return bytes;
}

/** Copies only durable fields. Per-run collection cursors must never be persisted. */
export function validateHistory(snapshot, expectedAppId) {
  if (!object(snapshot) || typeof snapshot.appId !== 'string' || !/^\d+$/.test(snapshot.appId)
      || (expectedAppId !== undefined && snapshot.appId !== expectedAppId)
      || !date(snapshot.startDate) || !object(snapshot.days)
      || typeof snapshot.syncedAt !== 'string' || !Number.isFinite(Date.parse(snapshot.syncedAt))
      || new Date(snapshot.syncedAt).toISOString() !== snapshot.syncedAt
      || snapshot.startDate > snapshot.syncedAt.slice(0, 10)) {
    fail('HISTORY_INVALID', '집계 이력의 앱·기간·자료 형식을 확인할 수 없습니다.');
  }
  const days = {};
  const entries = Object.entries(snapshot.days);
  if (entries.length > 20_000) fail('HISTORY_INVALID', '집계 이력이 지원하는 크기를 초과했습니다.');
  for (const [day, record] of entries.sort(([a], [b]) => a.localeCompare(b))) {
    if (!date(day) || day < snapshot.startDate || !object(record)
        || !Number.isSafeInteger(record.count) || record.count < 0
        || !date(record.processingDate) || record.processingDate < day
        || record.processingDate > snapshot.syncedAt.slice(0, 10)) {
      fail('HISTORY_INVALID', '집계 이력의 날짜별 자료를 확인할 수 없습니다.');
    }
    days[day] = { count: record.count, processingDate: record.processingDate };
  }
  const history = { appId: snapshot.appId, startDate: snapshot.startDate, days, syncedAt: snapshot.syncedAt };
  if (Buffer.byteLength(JSON.stringify(history)) > MAX_BYTES) {
    fail('HISTORY_INVALID', '집계 이력이 지원하는 크기를 초과했습니다.');
  }
  return history;
}

/** AES-256-GCM authenticates both the ciphertext and its fixed application purpose. */
export function encryptHistory(snapshot, key) {
  const history = validateHistory(snapshot);
  const keyBytes = decode(key, 32, 'HISTORY_KEY_INVALID');
  const iv = randomBytes(12);
  const cipher = createCipheriv('aes-256-gcm', keyBytes, iv);
  cipher.setAAD(PURPOSE);
  const ciphertext = Buffer.concat([cipher.update(JSON.stringify(history), 'utf8'), cipher.final()]);
  const envelope = JSON.stringify({ version: 1, iv: iv.toString('base64'),
    tag: cipher.getAuthTag().toString('base64'), ciphertext: ciphertext.toString('base64') });
  if (Buffer.byteLength(envelope) > MAX_BYTES) fail('HISTORY_INVALID', '집계 이력이 지원하는 크기를 초과했습니다.');
  return `${envelope}\n`;
}

export function decryptHistory(text, key, expectedAppId) {
  const keyBytes = decode(key, 32, 'HISTORY_KEY_INVALID');
  if (typeof text !== 'string' || Buffer.byteLength(text) > MAX_BYTES) {
    fail('HISTORY_DECRYPT_FAILED', '암호화된 집계 이력을 읽을 수 없습니다.');
  }
  let snapshot;
  try {
    const envelope = JSON.parse(text);
    if (!object(envelope) || envelope.version !== 1
        || Object.keys(envelope).sort().join(',') !== 'ciphertext,iv,tag,version') {
      fail('HISTORY_DECRYPT_FAILED', '암호화된 집계 이력 형식을 확인할 수 없습니다.');
    }
    const decipher = createDecipheriv('aes-256-gcm', keyBytes, decode(envelope.iv, 12));
    decipher.setAAD(PURPOSE);
    decipher.setAuthTag(decode(envelope.tag, 16));
    const plaintext = Buffer.concat([decipher.update(decode(envelope.ciphertext)), decipher.final()]);
    snapshot = JSON.parse(new TextDecoder('utf-8', { fatal: true }).decode(plaintext));
  } catch {
    fail('HISTORY_DECRYPT_FAILED', '집계 이력 복호화에 실패했습니다. 암호화 키와 이력 파일을 확인해 주세요.');
  }
  return validateHistory(snapshot, expectedAppId);
}
