import assert from 'node:assert/strict';
import test from 'node:test';
import { gzipSync } from 'node:zlib';

import { collectDownloads, createAppleJWT } from '../src/apple.mjs';

const NOW = new Date('2026-11-19T04:00:00Z');
const API = 'https://api.appstoreconnect.apple.com';
const HEADER = 'Date\tApp Apple Identifier\tDownload Type\tCounts\n';
const keys = await crypto.subtle.generateKey({ name: 'ECDSA', namedCurve: 'P-256' }, true, ['sign', 'verify']);
const privateBytes = new Uint8Array(await crypto.subtle.exportKey('pkcs8', keys.privateKey));
const privatePEM = `-----BEGIN PRIVATE KEY-----\n${Buffer.from(privateBytes).toString('base64')}\n-----END PRIVATE KEY-----`;
const ENV = { ASC_APP_ID: '1234', ASC_KEY_ID: 'KEY123', ASC_ISSUER_ID: 'issuer-id', ASC_PRIVATE_KEY: privatePEM };

function row(date, count, type = 'First-time Download', appId = '1234') {
  return `${date}\t${appId}\t${type}\t${count}\n`;
}

function metadata(id, attributes) { return { id, attributes }; }
function page(data, next = null) { return Response.json({ data, links: { next } }); }

function fixture(instances, override) {
  const calls = [];
  const fetchImpl = async (input, options) => {
    const url = new URL(input);
    calls.push({ url, options });
    const changed = await override?.(url, options, calls);
    if (changed) return changed;
    if (url.pathname === '/v1/apps/1234/analyticsReportRequests') {
      return page([metadata('request', { accessType: 'ONGOING', stoppedDueToInactivity: false })]);
    }
    if (url.pathname === '/v1/analyticsReportRequests/request/reports') {
      return page([metadata('detailed', { name: 'App Store Downloads Detailed' }), metadata('report', { name: 'App Store Downloads Standard' })]);
    }
    if (url.pathname === '/v1/analyticsReports/report/instances') {
      return page(instances.map((item) => metadata(item.id, { granularity: 'DAILY', processingDate: item.processingDate })));
    }
    for (const instance of instances) {
      if (url.pathname === `/v1/analyticsReportInstances/${instance.id}/segments`) {
        return page(instance.segments.map((_, index) => metadata(`${instance.id}-${index}`, { url: `https://reports.s3.amazonaws.com/${instance.id}/${index}.gz?signature=secret` })));
      }
      for (let index = 0; index < instance.segments.length; index += 1) {
        if (url.pathname === `/${instance.id}/${index}.gz`) return new Response(gzipSync(HEADER + instance.segments[index]));
      }
    }
    throw new Error('Unexpected mock URL.');
  };
  return { calls, fetchImpl };
}

test('JWT has valid ES256 signature, Apple audience, and a 15 minute lifetime', async () => {
  const token = await createAppleJWT(ENV, { now: NOW });
  const [header, payload, signature] = token.split('.');
  assert.deepEqual(JSON.parse(Buffer.from(header, 'base64url')), { alg: 'ES256', kid: 'KEY123', typ: 'JWT' });
  const claims = JSON.parse(Buffer.from(payload, 'base64url'));
  assert.equal(claims.iss, ENV.ASC_ISSUER_ID);
  assert.equal(claims.aud, 'appstoreconnect-v1');
  assert.equal(claims.iat, NOW.getTime() / 1000);
  assert.equal(claims.exp - claims.iat, 900);
  assert.equal(await crypto.subtle.verify({ name: 'ECDSA', hash: 'SHA-256' }, keys.publicKey, Buffer.from(signature, 'base64url'), new TextEncoder().encode(`${header}.${payload}`)), true);
});

test('newer processing dates replace old totals; all segments and download types are handled', async () => {
  const { fetchImpl, calls } = fixture([
    { id: 'older', processingDate: '2026-11-17', segments: [row('2026-11-16', 300)] },
    { id: 'newer', processingDate: '2026-11-18', segments: [row('2026-11-16', 2), row('2026-11-16', 3) + row('2026-11-17', 8, 'Redownload') + row('2026-11-15', 900, 'First-time Download', '9999')] },
  ]);
  const result = await collectDownloads(ENV, undefined, { fetchImpl, now: NOW });
  assert.deepEqual(result.days, {
    '2026-11-16': { count: 5, processingDate: '2026-11-18' },
    '2026-11-17': { count: 0, processingDate: '2026-11-18' },
  });
  assert.equal(result.appId, '1234');
  assert.equal(result.pendingInstances, 0);
  assert.equal(result.syncedAt, NOW.toISOString());
  for (const call of calls) {
    assert.equal(call.options.redirect, 'error');
    if (call.url.origin === API) assert.match(call.options.headers.Authorization, /^Bearer /);
    else assert.deepEqual(call.options.headers, {});
  }
});

test('paginates every collection and deduplicates repeated instance IDs', async () => {
  const item = { id: 'one', processingDate: '2026-11-18', segments: [row('2026-11-16', 4), row('2026-11-16', 6)] };
  const { fetchImpl, calls } = fixture([item], (url) => {
    if (url.origin !== API) return;
    if (!url.searchParams.has('cursor')) return page([], `${url.origin}${url.pathname}?cursor=next`);
    if (url.pathname.endsWith('/instances')) {
      const resource = metadata('one', { granularity: 'DAILY', processingDate: '2026-11-18' });
      return page([resource, resource]);
    }
  });
  const result = await collectDownloads(ENV, undefined, { fetchImpl, now: NOW });
  assert.equal(result.days['2026-11-16'].count, 10);
  assert.equal(calls.filter((call) => call.url.origin !== API).length, 2);
  assert.deepEqual(result.processedInstanceIds, ['one']);
});

test('limits cold-start work and resumes pending immutable instances on the next sync', async () => {
  const instances = [16, 17, 18].map((day) => ({ id: `day-${day}`, processingDate: `2026-11-${day}`, segments: [row(`2026-11-${day - 2}`, day)] }));
  const first = fixture(instances);
  const firstResult = await collectDownloads({ ...ENV, ASC_MAX_INSTANCES_PER_SYNC: '2' }, undefined, { fetchImpl: first.fetchImpl, now: NOW });
  assert.equal(firstResult.pendingInstances, 1);
  assert.deepEqual(firstResult.processedInstanceIds, ['day-18', 'day-17']);
  const second = fixture(instances);
  const secondResult = await collectDownloads(ENV, firstResult, { fetchImpl: second.fetchImpl, now: NOW });
  assert.equal(secondResult.pendingInstances, 0);
  assert.equal(Object.keys(secondResult.days).length, 3);
  assert.equal(second.calls.filter((call) => call.url.origin !== API).length, 1);
  assert.equal(firstResult.pendingInstances, 1);
});

test('request budget keeps an unfinished multi-segment instance entirely pending', async () => {
  const { fetchImpl, calls } = fixture([
    { id: 'newest', processingDate: '2026-11-18', segments: Array.from({ length: 20 }, () => row('2026-11-16', 1)) },
    { id: 'older', processingDate: '2026-11-17', segments: Array.from({ length: 20 }, () => row('2026-11-15', 1)) },
  ]);
  const result = await collectDownloads(ENV, undefined, { fetchImpl, now: NOW });
  assert.deepEqual(result.days, { '2026-11-16': { count: 20, processingDate: '2026-11-18' } });
  assert.deepEqual(result.processedInstanceIds, ['newest']);
  assert.equal(result.pendingInstances, 1);
  assert.ok(calls.length <= 40);
  assert.equal(calls.some((call) => call.url.pathname.startsWith('/older/')), false);
});

test('a failed collection never changes old state or leaks download URLs in the error', async () => {
  const previous = { appId: '1234', days: { '2026-11-15': { count: 2, processingDate: '2026-11-17' } }, processedInstanceIds: [] };
  const before = structuredClone(previous);
  const { fetchImpl } = fixture([
    { id: 'success', processingDate: '2026-11-18', segments: [row('2026-11-16', 9)] },
    { id: 'failure', processingDate: '2026-11-17', segments: [row('2026-11-15', 2)] },
  ], (url) => {
    if (url.pathname === '/failure/0.gz') throw new Error(`Network error at ${url}`);
  });
  await assert.rejects(collectDownloads(ENV, previous, { fetchImpl, now: NOW }), (error) => {
    assert.equal(error.code, 'NETWORK');
    assert.equal(error.message.includes('signature'), false);
    return true;
  });
  assert.deepEqual(previous, before);
});

test('rejects pagination to another origin and cyclic pages without forwarding authorization', async () => {
  const unsafe = fixture([], () => page([], 'https://attacker.invalid/v1/next'));
  await assert.rejects(collectDownloads(ENV, undefined, { fetchImpl: unsafe.fetchImpl, now: NOW }), { code: 'UNSAFE_URL' });
  assert.equal(unsafe.calls.length, 1);
  const cyclic = fixture([], (url) => page([], url.toString()));
  await assert.rejects(collectDownloads(ENV, undefined, { fetchImpl: cyclic.fetchImpl, now: NOW }), { code: 'PAGINATION' });
  assert.equal(cyclic.calls.length, 1);
});

test('validates schema and refuses inactive requests or a different app cache', async () => {
  const invalid = fixture([{ id: 'bad', processingDate: '2026-11-18', segments: [] }], (url) => {
    if (url.pathname.endsWith('/segments')) return page([metadata('bad', { url: 'https://reports.s3.amazonaws.com/bad.gz' })]);
    if (url.pathname === '/bad.gz') return new Response(gzipSync('Date\tCounts\n2026-11-16\t4\n'));
  });
  await assert.rejects(collectDownloads(ENV, undefined, { fetchImpl: invalid.fetchImpl, now: NOW }), { code: 'SCHEMA' });
  const inactive = fixture([], () => page([metadata('request', { accessType: 'ONGOING', stoppedDueToInactivity: true })]));
  await assert.rejects(collectDownloads(ENV, undefined, { fetchImpl: inactive.fetchImpl, now: NOW }), { code: 'REPORT_REQUEST' });
  await assert.rejects(collectDownloads(ENV, { appId: '9999', days: {} }, { now: NOW }), { code: 'CACHE_APP_MISMATCH' });
});

test('lifetime history survives retention and accepts corrections to an old date', async () => {
  const previous = { appId: '1234', startDate: '2026-01-01', days: {
    '2026-01-01': { count: 11, processingDate: '2026-01-03' },
    '2026-02-01': { count: 22, processingDate: '2026-02-03' },
  } };
  const { fetchImpl } = fixture([{ id: 'correction', processingDate: '2026-11-18', segments: [row('2026-01-01', 8)] }]);
  const result = await collectDownloads(ENV, previous, { fetchImpl, now: NOW });
  assert.equal(result.startDate, '2026-01-01');
  assert.equal(result.days['2026-01-01'].count, 8);
  assert.equal(result.days['2026-02-01'].count, 22);
  assert.equal(previous.days['2026-01-01'].count, 11);
});
