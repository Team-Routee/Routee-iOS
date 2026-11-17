import { readFile } from 'node:fs/promises';
import { createAppleJWT } from '../src/apple.mjs';

if (!process.argv.includes('--apply')) {
  console.log('준비 작업: 앱의 기존 ONGOING 요청을 조회하고, 없으면 ONGOING 보고서 생성을 요청합니다.');
  console.log('새 요청 생성에는 Admin API 키가 필요합니다. --apply 없이는 네트워크 요청을 보내지 않습니다.');
} else {
  try {
    const env = { ...process.env };
    if (env.ASC_PRIVATE_KEY_PATH && !env.ASC_PRIVATE_KEY) {
      env.ASC_PRIVATE_KEY = await readFile(env.ASC_PRIVATE_KEY_PATH, 'utf8');
    }
    if (!/^\d+$/.test(env.ASC_APP_ID ?? '')) throw new Error('configuration');
    const token = await createAppleJWT(env);
    const origin = 'https://api.appstoreconnect.apple.com';
    const headers = { Authorization: `Bearer ${token}`, 'content-type': 'application/json' };
    let next = `${origin}/v1/apps/${env.ASC_APP_ID}/analyticsReportRequests?filter%5BaccessType%5D=ONGOING&limit=200`;
    const requests = [];
    const visited = new Set();
    while (next) {
      const url = new URL(next, origin);
      if (url.origin !== origin || visited.has(url.href) || visited.size >= 10) throw new Error('pagination');
      visited.add(url.href);
      const response = await fetch(url, { headers, redirect: 'error', signal: AbortSignal.timeout(10_000) });
      if (!response.ok) throw new Error('list');
      const result = await response.json();
      if (!Array.isArray(result.data)) throw new Error('schema');
      requests.push(...result.data);
      next = result.links?.next;
    }
    const active = requests.filter(item => item.attributes?.accessType === 'ONGOING' && item.attributes.stoppedDueToInactivity === false);
    if (active.length) {
      console.log(`기존 활성 ONGOING 보고서 요청 ${active.length}개를 확인했습니다. 새 요청은 생성하지 않았습니다.`);
    } else {
      const response = await fetch(`${origin}/v1/analyticsReportRequests`, {
        method: 'POST', headers, redirect: 'error', signal: AbortSignal.timeout(10_000),
        body: JSON.stringify({ data: { type: 'analyticsReportRequests', attributes: { accessType: 'ONGOING' },
          relationships: { app: { data: { type: 'apps', id: env.ASC_APP_ID } } } } }),
      });
      if (!response.ok) throw new Error('creation');
      const result = await response.json();
      if (!result.data?.id) throw new Error('verification');
      console.log('ONGOING 보고서 생성 요청을 확인했습니다. 최초 생성에는 24~48시간이 걸릴 수 있습니다.');
    }
  } catch {
    console.error('보고서 요청 상태를 확인하지 못했습니다. API 키·권한·앱 ID를 확인하세요. 응답이 끊겼다면 재실행 시 기존 요청부터 조회합니다.');
    process.exitCode = 1;
  }
}
