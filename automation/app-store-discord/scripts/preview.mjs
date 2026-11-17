import { addDays, formatReport } from '../src/reports.mjs';

const now = new Date('2026-11-18T01:17:00Z');
const days = {};
for (let day = '2026-11-09'; day <= '2026-11-15'; day = addDays(day, 1)) {
  days[day] = { count: 3, processingDate: addDays(day, 2) };
}
console.log('예시 데이터입니다. 실제 루티 통계가 아니며 Discord에 전송하지 않습니다.\n');
console.log(formatReport({ days, syncedAt: now.toISOString() }, 'last_week', now));
