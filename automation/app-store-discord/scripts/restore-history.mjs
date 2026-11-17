import { appendFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';

import { HistoryError } from '../src/history.mjs';

const ARTIFACT_NAME = 'routee-download-history';
const WORKFLOW_PATH = '.github/workflows/app-store-downloads.yml';
const MAX_RESPONSE_BYTES = 2 * 1024 * 1024;

function fail(code, message) {
  throw new HistoryError(code, message);
}

function id(value) {
  return Number.isSafeInteger(value) && value > 0;
}

async function readJSON(response) {
  const reader = response.body?.getReader();
  if (!reader) fail('HISTORY_RESTORE_FAILED', '집계 이력 목록을 읽을 수 없습니다.');
  const chunks = [];
  let size = 0;
  try {
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      size += value.byteLength;
      if (size > MAX_RESPONSE_BYTES) {
        await reader.cancel();
        fail('HISTORY_RESTORE_FAILED', '집계 이력 목록이 지원하는 크기를 초과했습니다.');
      }
      chunks.push(value);
    }
    return JSON.parse(Buffer.concat(chunks).toString('utf8'));
  } finally {
    reader.releaseLock();
  }
}

/** Only selects metadata; download-artifact downloads the exact encrypted artifact ID. */
export async function findHistoryArtifact(env, { fetchImpl = fetch } = {}) {
  const repository = env.GITHUB_REPOSITORY;
  if (typeof repository !== 'string' || !/^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/.test(repository)
      || typeof env.GITHUB_TOKEN !== 'string' || !env.GITHUB_TOKEN.trim()) {
    fail('HISTORY_RESTORE_CONFIGURATION', '집계 이력 조회용 GitHub 실행 설정을 확인해 주세요.');
  }
  let requests = 0;
  async function request(path) {
    if (++requests > 80) fail('HISTORY_RESTORE_FAILED', '집계 이력 조회가 실행 한도를 초과했습니다.');
    try {
      const response = await fetchImpl(`https://api.github.com/repos/${repository}${path}`, {
        headers: { Authorization: `Bearer ${env.GITHUB_TOKEN}`, Accept: 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28' },
        redirect: 'error', signal: AbortSignal.timeout(10_000),
      });
      if (!response.ok) fail('HISTORY_RESTORE_FAILED', 'GitHub 집계 이력 조회에 실패했습니다.');
      return await readJSON(response);
    } catch {
      fail('HISTORY_RESTORE_FAILED', 'GitHub 집계 이력을 확인하지 못해 초기 이력으로 대체하지 않았습니다.');
    }
  }

  const artifacts = new Map();
  let complete = false;
  for (let page = 1; page <= 40; page++) {
    const data = await request(`/actions/artifacts?name=${ARTIFACT_NAME}&per_page=100&page=${page}`);
    if (!Array.isArray(data.artifacts) || !Number.isSafeInteger(data.total_count) || data.total_count < 0) {
      fail('HISTORY_RESTORE_FAILED', 'GitHub 집계 이력 목록 형식을 확인할 수 없습니다.');
    }
    for (const artifact of data.artifacts) {
      if (artifact.name !== ARTIFACT_NAME || !id(artifact.id) || !id(artifact.workflow_run?.id)
          || typeof artifact.expired !== 'boolean' || !Number.isFinite(Date.parse(artifact.created_at))) {
        fail('HISTORY_RESTORE_FAILED', 'GitHub 집계 이력 메타데이터를 확인할 수 없습니다.');
      }
      artifacts.set(artifact.id, artifact);
    }
    if (data.artifacts.length < 100 || artifacts.size >= data.total_count) {
      complete = true;
      break;
    }
  }
  if (!complete) fail('HISTORY_RESTORE_FAILED', '집계 이력 목록을 모두 확인하지 못했습니다.');

  const candidates = [...artifacts.values()]
    .filter(artifact => artifact.workflow_run.head_branch === 'develop')
    .sort((a, b) => Date.parse(b.created_at) - Date.parse(a.created_at) || b.id - a.id);
  const runs = new Map();
  for (const artifact of candidates) {
    const runId = artifact.workflow_run.id;
    if (!runs.has(runId)) runs.set(runId, await request(`/actions/runs/${runId}`));
    const run = runs.get(runId);
    if (!id(run.id) || run.id !== runId || typeof run.path !== 'string' || typeof run.event !== 'string'
        || typeof run.repository?.full_name !== 'string' || typeof run.head_repository?.full_name !== 'string') {
      fail('HISTORY_RESTORE_FAILED', '집계 이력을 생성한 실행 정보를 확인할 수 없습니다.');
    }
    if (run.path !== WORKFLOW_PATH || run.head_branch !== 'develop'
        || !['schedule', 'workflow_dispatch'].includes(run.event)
        || run.repository.full_name.toLowerCase() !== repository.toLowerCase()
        || run.head_repository.full_name.toLowerCase() !== repository.toLowerCase()) continue;
    if (artifact.expired) fail('HISTORY_EXPIRED', '이전 집계 이력이 만료되었습니다. 누적 이력을 복구한 뒤 다시 실행해 주세요.');
    return { runId, artifactId: artifact.id };
  }
  return null;
}

export async function main(env = process.env, { find = findHistoryArtifact, write = appendFile } = {}) {
  try {
    if (!env.GITHUB_OUTPUT) fail('HISTORY_RESTORE_CONFIGURATION', 'GitHub 출력 파일 설정이 필요합니다.');
    const artifact = await find(env);
    await write(env.GITHUB_OUTPUT, `run_id=${artifact?.runId ?? ''}\nartifact_id=${artifact?.artifactId ?? ''}\n`, 'utf8');
    console.log(artifact ? '암호화된 집계 이력을 선택했습니다.' : '기존 집계 이력이 없어 암호화된 초기 이력을 사용합니다.');
    return 0;
  } catch (error) {
    const safe = error instanceof HistoryError ? error
      : new HistoryError('HISTORY_RESTORE_FAILED', '집계 이력 복원을 준비하지 못했습니다.');
    console.error(`${safe.code}: ${safe.message}`);
    return 1;
  }
}

if (process.argv[1] && pathToFileURL(process.argv[1]).href === import.meta.url) {
  process.exitCode = await main();
}
