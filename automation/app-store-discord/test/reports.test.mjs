import assert from 'node:assert/strict';
import test from 'node:test';
import { addDays, formatReport, lastWeek, summarize } from '../src/reports.mjs';

const now = new Date('2026-11-18T01:17:00Z');
function sample() {
  const days = {};
  for (let date = '2026-11-09'; date <= '2026-11-15'; date = addDays(date, 1)) {
    days[date] = { count: 3, processingDate: addDays(date, 2) };
  }
  return { days, syncedAt: now.toISOString() };
}

test('last week is Monday–Sunday UTC across year boundary', () => {
  assert.deepEqual(lastWeek(now), { start: '2026-11-09', end: '2026-11-15' });
  assert.deepEqual(lastWeek(new Date('2027-01-04T01:00:00Z')),
    { start: '2026-12-28', end: '2027-01-03' });
});

test('weekly report totals all seven finalized days including explicit zero', () => {
  const snapshot = sample();
  snapshot.days['2026-11-10'].count = 0;
  const result = summarize(snapshot, 'last_week', now);
  assert.equal(result.total, 18);
  assert.equal(result.complete, true);
  assert.match(formatReport(snapshot, 'last_week', now), /18건/);
});

test('absent dates are missing, not zero', () => {
  const snapshot = sample();
  delete snapshot.days['2026-11-11'];
  assert.equal(summarize(snapshot, 'last_week', now).complete, false);
  assert.match(formatReport(snapshot, 'last_week', now), /전체 합계 확인 대기/);
  assert.match(formatReport(snapshot, 'last_week', now), /미확인 날짜: 2026-11-11/);
});

test('old partial data does not become finalized merely by waiting', () => {
  const snapshot = sample();
  snapshot.days['2026-11-15'].processingDate = '2026-11-16';
  assert.deepEqual(summarize(snapshot, 'last_week', now).missing, ['2026-11-15']);
});

test('rolling range stays relative to now so an outage cannot disguise an old period as recent', () => {
  const result = summarize(sample(), 'last_7_days', now);
  assert.equal(result.end, '2026-11-16');
  assert.equal(result.start, '2026-11-10');
  assert.equal(result.total, 18);
  assert.equal(result.complete, false);
  assert.equal(summarize(sample(), 'last_30_days', now).missing.length, 23);
});

test('empty snapshot cannot report a complete zero', () => {
  const report = summarize(null, 'last_week', now);
  assert.equal(report.complete, false);
  assert.equal(report.missing.length, 7);
});
