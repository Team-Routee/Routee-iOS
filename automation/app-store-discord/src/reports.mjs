const DAY_MS = 86_400_000;
export const PERIODS = new Set(['last_week', 'last_7_days', 'last_30_days']);

export function dateOnly(value) {
  return new Date(value).toISOString().slice(0, 10);
}

export function addDays(value, count) {
  return dateOnly(Date.parse(`${value}T00:00:00Z`) + count * DAY_MS);
}

export function lastWeek(now = new Date()) {
  const today = dateOnly(now);
  const monday = addDays(today, -((now.getUTCDay() + 6) % 7));
  return { start: addDays(monday, -7), end: addDays(monday, -1) };
}

function finalized(day, record, now) {
  return record && Number.isSafeInteger(record.count) && record.count >= 0
    && /^\d{4}-\d{2}-\d{2}$/.test(record.processingDate)
    && record.processingDate >= addDays(day, 2)
    && day <= addDays(dateOnly(now), -2);
}

export function summarize(snapshot, period = 'last_week', now = new Date()) {
  if (!PERIODS.has(period)) throw new Error('지원하지 않는 조회 기간입니다.');
  const days = snapshot?.days ?? {};
  const available = Object.keys(days).filter(day => finalized(day, days[day], now)).sort();
  let range;
  if (period === 'last_week') {
    range = lastWeek(now);
  } else {
    const end = addDays(dateOnly(now), -2);
    range = { start: addDays(end, period === 'last_30_days' ? -29 : -6), end };
  }
  const missing = [];
  let total = 0;
  let count = 0;
  for (let day = range.start; day <= range.end; day = addDays(day, 1)) {
    if (finalized(day, days[day], now)) {
      total += days[day].count;
      count++;
    } else {
      missing.push(day);
    }
  }
  if (!Number.isSafeInteger(total)) throw new Error('집계 범위를 초과했습니다.');
  return { ...range, total, availableDays: count, missing, complete: missing.length === 0,
    syncedAt: snapshot?.syncedAt ?? null, latestDate: available.at(-1) ?? null };
}

export function formatReport(snapshot, period = 'last_week', now = new Date()) {
  const report = summarize(snapshot, period, now);
  const title = { last_week: '지난주', last_7_days: '최근 7일', last_30_days: '최근 30일' }[period];
  const lines = ['📊 루티 최초 다운로드 리포트', `${title}: ${report.start} ~ ${report.end} (UTC)`];
  if (report.complete) {
    lines.push(`최초 다운로드: **${report.total.toLocaleString('ko-KR')}건**`);
  } else {
    lines.push('**전체 합계 확인 대기**',
      `확인된 ${report.availableDays}일의 소계: ${report.total.toLocaleString('ko-KR')}건`,
      `미확인 날짜: ${report.missing.join(', ')}`,
      '보고서가 없거나 아직 완성되지 않은 날짜는 0건으로 계산하지 않습니다.');
  }
  if (report.latestDate) lines.push(`완성된 데이터의 최신 날짜: ${report.latestDate} (UTC)`);
  if (report.syncedAt) lines.push(`마지막 수집: ${new Date(report.syncedAt).toISOString().replace('T', ' ').slice(0, 16)} UTC`);
  else lines.push('아직 Apple 보고서를 수집하지 못했습니다.');
  lines.push('Apple 계정 기준 최초 받기/구입 · 재다운로드/업데이트 제외');
  return lines.join('\n');
}
