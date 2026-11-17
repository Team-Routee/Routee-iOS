import assert from 'node:assert/strict';
import test from 'node:test';
import { addDays, formatReport, lastWeek, summarize, summarizeLifetime } from '../src/reports.mjs';

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

function history(start, end, count = 2) {
  const days = {};
  for (let day = start; day <= end; day = addDays(day, 1)) {
    days[day] = { count, processingDate: addDays(day, 2) };
  }
  return { startDate: start, days };
}

test('lifetime includes history outside the selected weekly period', () => {
  const snapshot = history('2026-10-30', '2026-11-16');
  assert.equal(summarize(snapshot, 'last_week', now).total, 14);
  assert.deepEqual(summarizeLifetime(snapshot, now), {
    configured: true, start: '2026-10-30', end: '2026-11-16', targetEnd: '2026-11-16',
    total: 36, complete: true, missingFrom: null, availableDays: 18,
  });
  const content = formatReport(snapshot, 'last_week', now);
  assert.match(content, /최초 다운로드: \*\*14건\*\*/);
  assert.match(content, /전체 최초 다운로드: \*\*36건\*\*/);
  assert.match(content, /누적 기간: 2026-10-30 ~ 2026-11-16 \(UTC\)/);
  assert.doesNotMatch(content, /이후 집계 확인 대기/);
});

test('lifetime crosses a year boundary and includes confirmed zero days', () => {
  const snapshot = history('2026-12-30', '2027-01-03');
  snapshot.days['2027-01-01'].count = 0;
  const result = summarizeLifetime(snapshot, new Date('2027-01-05T12:00:00Z'));
  assert.equal(result.total, 8);
  assert.equal(result.end, '2027-01-03');
  assert.equal(result.complete, true);
});

test('lifetime stops at the first gap and labels the verified earlier total', () => {
  const snapshot = history('2026-11-01', '2026-11-16');
  delete snapshot.days['2026-11-04'];
  snapshot.days['2026-11-05'].count = 100;
  const result = summarizeLifetime(snapshot, now);
  assert.equal(result.total, 6);
  assert.equal(result.end, '2026-11-03');
  assert.equal(result.missingFrom, '2026-11-04');
  assert.equal(result.complete, false);
  const content = formatReport(snapshot, 'last_week', now);
  assert.match(content, /전체 최초 다운로드: \*\*6건\*\*/);
  assert.match(content, /2026-11-03 기준 · 이후 집계 확인 대기/);
  assert.equal(summarize(snapshot, 'last_week', now).complete, true);
});

test('a nonfinalized day cannot extend lifetime even when later dates are complete', () => {
  const snapshot = history('2026-11-01', '2026-11-16');
  snapshot.days['2026-11-03'].processingDate = '2026-11-04';
  assert.equal(summarizeLifetime(snapshot, now).end, '2026-11-02');
  assert.equal(summarizeLifetime(snapshot, now).total, 4);
});

test('corrected daily totals replace their old contribution to lifetime', () => {
  const snapshot = history('2026-11-01', '2026-11-16');
  assert.equal(summarizeLifetime(snapshot, now).total, 32);
  snapshot.days['2026-11-02'] = { count: 5, processingDate: '2026-11-17' };
  assert.equal(summarizeLifetime(snapshot, now).total, 35);
});

test('missing launch history is always visible without inventing a lifetime zero', () => {
  assert.equal(summarizeLifetime(sample(), now).configured, false);
  assert.equal(summarizeLifetime(sample(), now).total, null);
  const snapshot = history('2026-11-01', '2026-11-16');
  delete snapshot.days['2026-11-01'];
  assert.equal(summarizeLifetime(snapshot, now).end, null);
  assert.equal(summarizeLifetime(snapshot, now).total, null);
  for (const input of [null, sample(), snapshot]) {
    const content = formatReport(input, 'last_week', now);
    assert.match(content, /전체 최초 다운로드: 확인 대기/);
    assert.doesNotMatch(content, /전체 최초 다운로드: \*\*0건/);
  }
});

test('lifetime rejects impossible launch dates and overflowing totals', () => {
  assert.throws(() => summarizeLifetime({ startDate: '2026-02-30', days: {} }, now));
  const snapshot = history('2026-11-15', '2026-11-16', Number.MAX_SAFE_INTEGER);
  assert.throws(() => summarizeLifetime(snapshot, now), /집계 범위/);
});
