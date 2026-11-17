import { appendFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';

import { ReportRunError, runReport } from '../src/run-report.mjs';

export function parseArguments(args, env = process.env) {
  const options = { period: 'last_week', send: false, summaryPath: env.GITHUB_STEP_SUMMARY };
  const seen = new Set();
  for (let index = 0; index < args.length; index++) {
    const argument = args[index];
    const [flag, ...inlineParts] = argument.split('=');
    if (seen.has(flag)) throw new ReportRunError('INVALID_ARGUMENT', '같은 실행 옵션을 여러 번 지정할 수 없습니다.');
    seen.add(flag);
    if (flag === '--send' && inlineParts.length === 0) options.send = true;
    else if (flag === '--help' && inlineParts.length === 0) options.help = true;
    else if (flag === '--period' || flag === '--summary-path') {
      const value = inlineParts.length ? inlineParts.join('=') : args[++index];
      if (!value || value.startsWith('--')) throw new ReportRunError('INVALID_ARGUMENT', '실행 옵션의 값을 확인해 주세요.');
      options[flag === '--period' ? 'period' : 'summaryPath'] = value;
    } else throw new ReportRunError('INVALID_ARGUMENT', '지원하지 않는 실행 옵션입니다.');
  }
  return options;
}

export async function main(args = process.argv.slice(2), env = process.env, { execute = runReport } = {}) {
  let options;
  try {
    options = parseArguments(args, env);
    if (options.help) {
      console.log('node scripts/run-report.mjs [--period last_week|last_7_days|last_30_days] [--send] [--summary-path FILE]');
      console.log('--send가 없으면 조회만 검증합니다. 통계 수치와 본문은 콘솔이나 GitHub 요약에 출력하지 않습니다.');
      return 0;
    }
    const result = await execute(env, options);
    if (options.summaryPath) {
      try {
        await appendFile(options.summaryPath, result.summary, 'utf8');
      } catch {
        console.error('실행 요약 파일을 저장하지 못했습니다. 리포트 처리 결과는 유지됩니다.');
      }
    }
    console.log(`루티 리포트 실행 완료: ${result.status}`);
    return 0;
  } catch (error) {
    const safe = error instanceof ReportRunError ? error
      : new ReportRunError('REPORT_RUN_FAILED', '리포트 실행을 완료하지 못했습니다.');
    const message = `${safe.code}: ${safe.message}`;
    console.error(message);
    const summaryPath = options?.summaryPath ?? env.GITHUB_STEP_SUMMARY;
    if (summaryPath) {
      try {
        await appendFile(summaryPath, `## 루티 다운로드 리포트 실행\n\n- 실행 결과: 실패\n- ${message}\n`, 'utf8');
      } catch {
        console.error('실행 요약 파일을 저장하지 못했습니다.');
      }
    }
    return 1;
  }
}

if (process.argv[1] && pathToFileURL(process.argv[1]).href === import.meta.url) {
  process.exitCode = await main();
}
