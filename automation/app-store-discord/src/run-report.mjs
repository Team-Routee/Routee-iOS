import { collectDownloads } from './apple.mjs';
import { formatReport, PERIODS, summarize } from './reports.mjs';
import { sendWebhook } from './webhook.mjs';

export class ReportRunError extends Error {
  constructor(code, message, delivery) {
    super(message);
    this.name = 'ReportRunError';
    this.code = code;
    if (delivery) this.delivery = delivery;
  }
}

function fail(code, message) {
  throw new ReportRunError(code, message);
}

function validateSnapshot(snapshot, appId) {
  if (!snapshot || snapshot.appId !== appId || !snapshot.days || typeof snapshot.days !== 'object'
      || Array.isArray(snapshot.days) || !Number.isSafeInteger(snapshot.pendingInstances)
      || snapshot.pendingInstances < 0 || !Array.isArray(snapshot.processedInstanceIds)
      || snapshot.processedInstanceIds.some(id => typeof id !== 'string' || !id)
      || new Set(snapshot.processedInstanceIds).size !== snapshot.processedInstanceIds.length
      || typeof snapshot.syncedAt !== 'string' || !Number.isFinite(Date.parse(snapshot.syncedAt))) {
    fail('INVALID_COLLECTION_RESULT', 'Apple 보고서 수집 결과를 확인할 수 없습니다.');
  }
}

function collectionError(error) {
  if (error?.code === 'REPORT_NOT_READY') {
    return new ReportRunError('APPLE_REPORT_NOT_READY', 'Apple 보고서가 아직 준비되지 않았습니다. 최초 생성에는 24~48시간이 걸릴 수 있습니다.');
  }
  if (error?.code === 'REPORT_REQUEST') {
    return new ReportRunError('APPLE_REPORT_REQUEST_REQUIRED', '활성 ONGOING 보고서 요청을 먼저 설정해 주세요.');
  }
  return new ReportRunError('APPLE_COLLECTION_FAILED', 'Apple 보고서를 수집하지 못했습니다. API 키·권한·보고서 상태를 확인해 주세요.');
}

function publicSummary(report, status) {
  const label = {
    preview: '조회 검증 완료 · 디스코드 전송 안 함',
    preview_partial: '조회 검증 완료 · 일부 자료 미확인 · 디스코드 전송 안 함',
    sent: '디스코드 전송 완료',
    sent_partial: '디스코드 전송 완료 · 일부 자료 미확인',
  }[status];
  // This repository is public. Counts, raw reports and message text must never appear here.
  return ['## 루티 다운로드 리포트 실행', '',
    `- 집계 기간: ${report.start} ~ ${report.end} (UTC)`,
    `- 실행 결과: ${label}`,
    '- 실제 다운로드 수와 리포트 본문은 GitHub 로그·요약에 기록하지 않습니다.', ''].join('\n');
}

/** Stateless per-run collection. Only the returned content is sent to the private Discord channel. */
export async function runReport(env, {
  period = 'last_week', send = false, now = new Date(), maxRounds = 6,
  collect = collectDownloads, deliver = sendWebhook,
} = {}) {
  if (!PERIODS.has(period)) fail('INVALID_PERIOD', '조회 기간은 last_week, last_7_days, last_30_days 중 하나여야 합니다.');
  if (typeof send !== 'boolean' || !Number.isFinite(now.getTime())
      || !Number.isInteger(maxRounds) || maxRounds < 1 || maxRounds > 10) {
    fail('INVALID_OPTIONS', '리포트 실행 설정을 확인해 주세요.');
  }
  if (send) {
    const attempt = Number(env.GITHUB_RUN_ATTEMPT ?? 1);
    if (!Number.isInteger(attempt) || attempt < 1) fail('INVALID_RUN_ATTEMPT', 'GitHub 실행 회차를 확인할 수 없습니다.');
    if (attempt > 1) {
      fail('REPLAY_BLOCKED', '중복 전송을 막기 위해 재실행에서는 전송하지 않습니다. Discord 채널을 확인한 뒤 새 Run workflow로 실행해 주세요.');
    }
  }
  const appId = String(env.ASC_APP_ID ?? '').trim();
  const collectionEnv = { ...env, ASC_APP_ID: appId, ASC_MAX_INSTANCES_PER_SYNC: env.ASC_MAX_INSTANCES_PER_SYNC ?? '20' };
  let snapshot = { days: {} };
  let finished = false;
  for (let round = 0; round < maxRounds; round++) {
    const previousIds = new Set(snapshot.processedInstanceIds ?? []);
    let next;
    try {
      next = await collect(collectionEnv, snapshot, { now });
    } catch (error) {
      throw collectionError(error);
    }
    validateSnapshot(next, appId);
    snapshot = next;
    if (snapshot.pendingInstances === 0) {
      finished = true;
      break;
    }
    if (!snapshot.processedInstanceIds.some(id => !previousIds.has(id))) {
      fail('COLLECTION_NO_PROGRESS', '남은 보고서를 수집하지 못했습니다. 파일 크기나 수집 한도를 확인해 주세요.');
    }
  }
  if (!finished) fail('COLLECTION_LIMIT_REACHED', '보고서 수집이 실행 한도 안에 완료되지 않아 전송하지 않았습니다.');

  let report;
  let content;
  try {
    report = summarize(snapshot, period, now);
    content = formatReport(snapshot, period, now);
  } catch {
    fail('REPORT_FORMAT_FAILED', '수집 자료를 리포트로 변환하지 못해 전송하지 않았습니다.');
  }
  let status = report.complete ? 'preview' : 'preview_partial';
  if (send) {
    try {
      await deliver(env.DISCORD_WEBHOOK_URL, content);
    } catch (error) {
      const knownFailure = error?.delivery === 'not_sent';
      throw new ReportRunError(knownFailure ? 'WEBHOOK_NOT_SENT' : 'WEBHOOK_DELIVERY_UNCERTAIN',
        knownFailure ? '디스코드가 전송을 거절했습니다. 웹훅 설정을 확인해 주세요.'
          : '디스코드 전송 결과를 확인할 수 없습니다. 재전송하기 전에 채널을 확인해 주세요.',
        knownFailure ? 'not_sent' : 'unknown');
    }
    status = report.complete ? 'sent' : 'sent_partial';
  }
  return { snapshot, content, status, summary: publicSummary(report, status) };
}
