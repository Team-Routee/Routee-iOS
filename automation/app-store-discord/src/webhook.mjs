const ID_PATTERN = /^\d{1,25}$/;

export class WebhookDeliveryError extends Error {
  constructor(code, message, delivery, httpStatus) {
    super(message);
    this.name = "WebhookDeliveryError";
    this.code = code;
    // unknown means Discord may have accepted the message; do not retry automatically.
    this.delivery = delivery;
    if (httpStatus !== undefined) this.httpStatus = httpStatus;
  }
}

function webhookEndpoint(value) {
  let url;
  try {
    url = new URL(value);
  } catch {
    throw new WebhookDeliveryError("INVALID_WEBHOOK", "디스코드 웹훅 주소를 확인해 주세요.", "not_sent");
  }
  if (url.protocol !== "https:" || url.hostname !== "discord.com" || url.port || url.username
      || url.password || url.hash
      || !/^\/api\/(?:v10\/)?webhooks\/\d{1,25}\/[A-Za-z\d._-]+$/.test(url.pathname)
      || [...url.searchParams.keys()].some((key) => !["thread_id", "wait"].includes(key))
      || (url.searchParams.has("thread_id") && !ID_PATTERN.test(url.searchParams.get("thread_id")))) {
    throw new WebhookDeliveryError("INVALID_WEBHOOK", "디스코드 웹훅 주소를 확인해 주세요.", "not_sent");
  }
  url.searchParams.set("wait", "true");
  return url;
}

/** Sends once. Callers must persist an uncertain outcome instead of blindly retrying. */
export async function sendWebhook(webhookURL, content, { fetchImpl = fetch } = {}) {
  const url = webhookEndpoint(webhookURL);
  if (typeof content !== "string" || !content.trim() || content.length > 2000) {
    throw new WebhookDeliveryError("INVALID_MESSAGE", "전송할 리포트 형식을 확인해 주세요.", "not_sent");
  }
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 10_000);
  try {
    const response = await fetchImpl(url.toString(), {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ content, allowed_mentions: { parse: [] } }),
      signal: controller.signal,
      redirect: "error",
    });
    if (!response.ok) {
      const notSent = response.status >= 400 && response.status < 500 && response.status !== 408;
      throw new WebhookDeliveryError(
        response.status === 429 ? "WEBHOOK_RATE_LIMITED" : "WEBHOOK_REJECTED",
        "디스코드 리포트 전송을 완료하지 못했습니다.",
        notSent ? "not_sent" : "unknown",
        response.status,
      );
    }
    let result;
    try {
      result = await response.json();
    } catch {
      throw new WebhookDeliveryError("WEBHOOK_RESPONSE_UNKNOWN", "디스코드 전송 결과를 확인할 수 없습니다.", "unknown");
    }
    if (typeof result?.id !== "string" || !ID_PATTERN.test(result.id)) {
      throw new WebhookDeliveryError("WEBHOOK_RESPONSE_UNKNOWN", "디스코드 전송 결과를 확인할 수 없습니다.", "unknown");
    }
    return { id: result.id };
  } catch (error) {
    if (error instanceof WebhookDeliveryError) throw error;
    // Fetch errors may include the token-bearing URL. Never retain the raw error/cause.
    throw new WebhookDeliveryError("WEBHOOK_DELIVERY_UNKNOWN", "디스코드 전송 결과를 확인할 수 없습니다.", "unknown");
  } finally {
    clearTimeout(timeout);
  }
}
