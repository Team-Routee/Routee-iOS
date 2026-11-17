import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import test from 'node:test';

import { findHistoryArtifact, main } from '../scripts/restore-history.mjs';
import { decryptHistory, encryptHistory, validateHistory } from '../src/history.mjs';

const key = randomBytes(32).toString('base64');
const history = {
  appId: '123', startDate: '2026-01-01', syncedAt: '2026-01-05T01:00:00.000Z',
  days: { '2026-01-01': { count: 27, processingDate: '2026-01-03' },
    '2026-01-02': { count: 0, processingDate: '2026-01-04' } },
};
const env = { GITHUB_REPOSITORY: 'example/repository', GITHUB_TOKEN: 'private-token' };

function artifact(artifactId, runId, createdAt, extra = {}) {
  return { id: artifactId, name: 'routee-download-history', expired: false, created_at: createdAt,
    workflow_run: { id: runId, head_branch: 'develop' }, ...extra };
}

function run(runId, extra = {}) {
  return { id: runId, path: '.github/workflows/app-store-downloads.yml', event: 'workflow_dispatch',
    head_branch: 'develop', repository: { full_name: env.GITHUB_REPOSITORY },
    head_repository: { full_name: env.GITHUB_REPOSITORY }, ...extra };
}

function api(artifacts, runs = {}, calls = []) {
  return async (url, options) => {
    calls.push(url);
    assert.equal(new URL(url).origin, 'https://api.github.com');
    assert.equal(options.headers.Authorization, `Bearer ${env.GITHUB_TOKEN}`);
    assert.equal(options.redirect, 'error');
    const resource = url.includes('/actions/artifacts?')
      ? { total_count: artifacts.length, artifacts }
      : runs[url.split('/').at(-1)];
    assert.ok(resource, 'Unexpected API request');
    return Response.json(resource);
  };
}

test('encrypted history round trips with unique IVs and excludes per-run fields', () => {
  const withCursor = { ...history, processedInstanceIds: ['discard'], pendingInstances: 0 };
  const first = encryptHistory(withCursor, key);
  const second = encryptHistory(withCursor, key);
  assert.notEqual(first, second);
  assert.deepEqual(decryptHistory(first, key, '123'), history);
  assert.equal(first.includes('2026-01'), false);
  assert.equal(first.includes('count'), false);
  assert.equal(first.includes('discard'), false);
});

test('tampering, incorrect keys and cross-app histories are rejected', () => {
  const encrypted = encryptHistory(history, key);
  const envelope = JSON.parse(encrypted);
  const bytes = Buffer.from(envelope.ciphertext, 'base64');
  bytes[0] ^= 1;
  envelope.ciphertext = bytes.toString('base64');
  assert.throws(() => decryptHistory(JSON.stringify(envelope), key), { code: 'HISTORY_DECRYPT_FAILED' });
  assert.throws(() => decryptHistory(encrypted, randomBytes(32).toString('base64')), { code: 'HISTORY_DECRYPT_FAILED' });
  assert.throws(() => decryptHistory(encrypted, key, '456'), { code: 'HISTORY_INVALID' });
  assert.throws(() => decryptHistory(encrypted, 'bad-key'), { code: 'HISTORY_KEY_INVALID' });
});

test('invalid dates, future processing, unsafe counts and malformed envelopes fail closed', () => {
  for (const invalid of [
    { ...history, startDate: '2026-02-30' },
    { ...history, syncedAt: 'invalid' },
    { ...history, days: { '2026-02-30': { count: 1, processingDate: '2026-03-02' } } },
    { ...history, days: { '2026-01-01': { count: 1, processingDate: '2026-01-06' } } },
    { ...history, days: { '2026-01-01': { count: Number.MAX_SAFE_INTEGER + 1, processingDate: '2026-01-03' } } },
    { ...history, days: { '2025-12-31': { count: 1, processingDate: '2026-01-03' } } },
  ]) assert.throws(() => validateHistory(invalid), { code: 'HISTORY_INVALID' });
  for (const text of ['{}', 'not JSON', JSON.stringify({ ...JSON.parse(encryptHistory(history, key)), version: 2 }), 'x'.repeat(2 * 1024 * 1024 + 1)]) {
    assert.throws(() => decryptHistory(text, key), { code: 'HISTORY_DECRYPT_FAILED' });
  }
});

test('selects newest trusted artifact including a run whose later delivery failed', async () => {
  const artifacts = [artifact(1, 11, '2026-01-01T00:00:00Z'), artifact(2, 12, '2026-01-03T00:00:00Z')];
  const selected = await findHistoryArtifact(env, { fetchImpl: api(artifacts, { 12: run(12, { conclusion: 'failure' }) }) });
  assert.deepEqual(selected, { runId: 12, artifactId: 2 });
});

test('rejects untrusted branch, workflow, event and fork before choosing history', async () => {
  const artifacts = [
    artifact(5, 15, '2026-01-05T00:00:00Z', { workflow_run: { id: 15, head_branch: 'feature' } }),
    artifact(4, 14, '2026-01-04T00:00:00Z'), artifact(3, 13, '2026-01-03T00:00:00Z'),
    artifact(2, 12, '2026-01-02T00:00:00Z'), artifact(1, 11, '2026-01-01T00:00:00Z'),
  ];
  const calls = [];
  const selected = await findHistoryArtifact(env, { fetchImpl: api(artifacts, {
    14: run(14, { path: '.github/workflows/other.yml' }),
    13: run(13, { event: 'pull_request' }),
    12: run(12, { head_repository: { full_name: 'untrusted/fork' } }), 11: run(11),
  }, calls) });
  assert.deepEqual(selected, { runId: 11, artifactId: 1 });
  assert.ok(calls.every(url => !url.endsWith('/15')));
});

test('expired newest history and API failures do not silently fall back to an older seed', async () => {
  await assert.rejects(findHistoryArtifact(env, { fetchImpl: api([
    artifact(2, 12, '2026-01-02T00:00:00Z', { expired: true }), artifact(1, 11, '2026-01-01T00:00:00Z'),
  ], { 12: run(12) }) }), { code: 'HISTORY_EXPIRED' });
  await assert.rejects(findHistoryArtifact(env, { fetchImpl: async () => { throw new Error('private-token'); } }), error => {
    assert.equal(error.code, 'HISTORY_RESTORE_FAILED');
    assert.equal(error.message.includes('private-token'), false);
    return true;
  });
  assert.equal(await findHistoryArtifact(env, { fetchImpl: api([]) }), null);
});

test('restore CLI writes only artifact identifiers and masks unexpected failures', async t => {
  const messages = [];
  const output = [];
  t.mock.method(console, 'log', value => messages.push(value));
  t.mock.method(console, 'error', value => messages.push(value));
  assert.equal(await main({ ...env, GITHUB_OUTPUT: '/test-output' }, {
    find: async () => ({ runId: 12, artifactId: 2 }), write: async (...args) => output.push(args),
  }), 0);
  assert.deepEqual(output[0], ['/test-output', 'run_id=12\nartifact_id=2\n', 'utf8']);
  assert.equal(await main({ ...env, GITHUB_OUTPUT: '/test-output' }, {
    find: async () => { throw new Error('private-token'); }, write: async () => assert.fail('Must not write'),
  }), 1);
  assert.ok(messages.every(message => !message.includes('private-token')));
});
