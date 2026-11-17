import assert from 'node:assert/strict';
import { mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';

import { main, parseArguments } from '../scripts/run-report.mjs';
import { addDays } from '../src/reports.mjs';
import { ReportRunError, runReport } from '../src/run-report.mjs';

const now = new Date('2026-11-18T01:17:00Z');
const env = { ASC_APP_ID: '123', DISCORD_WEBHOOK_URL: 'https://discord.com/api/webhooks/123/private-token' };
function snapshot({ start = '2026-10-13', end = '2026-11-16', count = 17 } = {}) {
  const days = {};
  for (let day = start; day <= end; day = addDays(day, 1)) {
    days[day] = { count, processingDate: addDays(day, 2) };
  }
  return { appId: env.ASC_APP_ID, days, syncedAt: now.toISOString(), processedInstanceIds: ['all'], pendingInstances: 0 };
}

test('collects 35 days across multiple batches with the same reference time and sends once', async () => {
  let calls = 0;
  let deliveries = 0;
  const result = await runReport(env, { now, send: true, collect: async (config, previous, options) => {
    calls++;
    assert.equal(config.ASC_MAX_INSTANCES_PER_SYNC, '20');
    assert.equal(options.now, now);
    if (calls === 1) {
      assert.deepEqual(previous, { days: {} });
      return { ...snapshot({ start: '2026-10-29' }), processedInstanceIds: ['first'], pendingInstances: 15 };
    }
    assert.deepEqual(previous.processedInstanceIds, ['first']);
    return { ...snapshot(), processedInstanceIds: ['first', 'second'] };
  }, deliver: async (url, content) => {
    deliveries++;
    assert.equal(url, env.DISCORD_WEBHOOK_URL);
    assert.match(content, /119건/);
    return { id: '123' };
  } });
  assert.equal(calls, 2);
  assert.equal(deliveries, 1);
  assert.equal(result.status, 'sent');
});

test('public summary never contains metrics, raw data, message text or webhook', async () => {
  const result = await runReport(env, { now, collect: async () => snapshot({ count: 987654 }) });
  assert.match(result.content, /6,913,578건/);
  assert.equal(result.summary.includes('987654'), false);
  assert.equal(result.summary.includes('6,913,578'), false);
  assert.equal(result.summary.includes('최초 다운로드:'), false);
  assert.equal(result.summary.includes(env.DISCORD_WEBHOOK_URL), false);
  assert.match(result.summary, /2026-11-09 ~ 2026-11-15/);
});

test('dry-run validates all requested periods without sending', async () => {
  for (const [period, expected] of [['last_week', 119], ['last_7_days', 119], ['last_30_days', 510]]) {
    const result = await runReport(env, { now, period, collect: async () => snapshot(), deliver: async () => assert.fail('Must not send') });
    assert.equal(result.status, 'preview');
    assert.match(result.content, new RegExp(`${expected}건`));
  }
});

test('invalid period and replayed send are rejected before collecting', async () => {
  const collect = async () => assert.fail('Must not collect');
  await assert.rejects(runReport(env, { period: 'secret-in-invalid-input', collect }), { code: 'INVALID_PERIOD' });
  await assert.rejects(runReport({ ...env, GITHUB_RUN_ATTEMPT: '2' }, { send: true, collect }), { code: 'REPLAY_BLOCKED' });
  await assert.rejects(runReport({ ...env, GITHUB_RUN_ATTEMPT: '0' }, { send: true, collect }), { code: 'INVALID_RUN_ATTEMPT' });
});

test('a replay may still perform a preview without delivery', async () => {
  const result = await runReport({ ...env, GITHUB_RUN_ATTEMPT: '3' }, { now, collect: async () => snapshot() });
  assert.equal(result.status, 'preview');
});

test('no progress and round limit never send a truncated collection', async () => {
  let round = 0;
  const deliver = async () => assert.fail('Must not send');
  await assert.rejects(runReport(env, { now, send: true, deliver, collect: async () => ({ ...snapshot(), processedInstanceIds: [], pendingInstances: 2 }) }), { code: 'COLLECTION_NO_PROGRESS' });
  await assert.rejects(runReport(env, { now, send: true, maxRounds: 2, deliver,
    collect: async () => ({ ...snapshot(), processedInstanceIds: Array.from({ length: ++round }, (_, i) => String(i)), pendingInstances: 2 }) }),
  { code: 'COLLECTION_LIMIT_REACHED' });
});

test('collection/schema failures never send and discard potentially secret-bearing errors', async () => {
  const options = { now, send: true, deliver: async () => assert.fail('Must not send') };
  await assert.rejects(runReport(env, { ...options, collect: async () => { throw new Error(env.DISCORD_WEBHOOK_URL); } }), error => {
    assert.ok(error instanceof ReportRunError);
    assert.equal(error.code, 'APPLE_COLLECTION_FAILED');
    assert.equal(error.message.includes('private-token'), false);
    assert.equal(error.cause, undefined);
    return true;
  });
  await assert.rejects(runReport(env, { ...options, collect: async () => ({ ...snapshot(), pendingInstances: undefined }) }), { code: 'INVALID_COLLECTION_RESULT' });
  await assert.rejects(runReport(env, { ...options, collect: async () => ({ ...snapshot(), appId: 'other' }) }), { code: 'INVALID_COLLECTION_RESULT' });
});

test('not-ready/report-request failures have safe setup guidance', async () => {
  for (const [code, expected] of [['REPORT_NOT_READY', 'APPLE_REPORT_NOT_READY'], ['REPORT_REQUEST', 'APPLE_REPORT_REQUEST_REQUIRED']]) {
    await assert.rejects(runReport(env, { now, collect: async () => { throw Object.assign(new Error('secret'), { code }); } }), { code: expected });
  }
});

test('partial and empty reports do not invent a complete zero', async () => {
  const partial = snapshot();
  delete partial.days['2026-11-11'];
  let received;
  const result = await runReport(env, { now, send: true, collect: async () => partial, deliver: async (_, content) => { received = content; } });
  assert.equal(result.status, 'sent_partial');
  assert.match(received, /전체 합계 확인 대기/);
  assert.match(received, /확인된 6일의 소계: 102건/);
  const empty = await runReport(env, { now, collect: async () => ({ ...snapshot(), days: {} }) });
  assert.equal(empty.status, 'preview_partial');
  assert.doesNotMatch(empty.content, /최초 다운로드: \*\*0건/);
  assert.equal(empty.summary.includes('102건'), false);
});

test('delivery errors remain classified but never expose credentials or retry', async () => {
  for (const delivery of ['not_sent', 'unknown', undefined]) {
    let sends = 0;
    await assert.rejects(runReport(env, { now, send: true, collect: async () => snapshot(), deliver: async () => {
      sends++;
      throw Object.assign(new Error(env.DISCORD_WEBHOOK_URL), { delivery });
    } }), error => {
      assert.equal(error.delivery, delivery === 'not_sent' ? 'not_sent' : 'unknown');
      assert.equal(error.message.includes('private-token'), false);
      assert.equal(error.cause, undefined);
      return true;
    });
    assert.equal(sends, 1);
  }
});

test('CLI accepts explicit options and GitHub summary path while rejecting unknown input safely', () => {
  assert.deepEqual(parseArguments(['--send', '--period', 'last_30_days'], { GITHUB_STEP_SUMMARY: '/tmp/summary' }),
    { send: true, period: 'last_30_days', summaryPath: '/tmp/summary' });
  assert.equal(parseArguments(['--summary-path=/tmp/a=b'], {}).summaryPath, '/tmp/a=b');
  for (const args of [['--period'], ['--send=true'], ['--unknown-secret'], ['--send', '--send']]) {
    assert.throws(() => parseArguments(args, {}), error => error instanceof ReportRunError && !error.message.includes('unknown-secret'));
  }
});

test('a summary file failure preserves a successful send status without leaking its path or report', async t => {
  const directory = await mkdtemp(join(tmpdir(), 'routee-private-summary-'));
  t.after(() => rm(directory, { recursive: true, force: true }));
  const messages = [];
  t.mock.method(console, 'log', message => messages.push(message));
  t.mock.method(console, 'error', message => messages.push(message));
  let executions = 0;
  const exitCode = await main(['--send'], { GITHUB_STEP_SUMMARY: directory }, { execute: async () => {
    executions++;
    return { status: 'sent', summary: 'safe summary', content: 'private metric 987654' };
  } });
  assert.equal(exitCode, 0);
  assert.equal(executions, 1);
  assert.ok(messages.some(message => message === '루티 리포트 실행 완료: sent'));
  assert.ok(messages.some(message => message.includes('요약 파일을 저장하지 못했습니다')));
  assert.ok(messages.every(message => !message.includes(directory) && !message.includes('987654') && !message.includes('REPORT_RUN_FAILED')));
});
