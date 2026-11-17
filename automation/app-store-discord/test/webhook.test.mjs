import assert from "node:assert/strict";
import { test } from "node:test";

import { sendWebhook, WebhookDeliveryError } from "../src/webhook.mjs";

const neverRead = () => assert.fail("Invalid input must not send a request");

const webhookURL = "https://discord.com/api/webhooks/123456789012345678/EXAMPLE_TOKEN";

test("webhook waits for acknowledgment, disables mentions, and returns only message ID", async () => {
  const result = await sendWebhook(webhookURL + "?wait=false", "주간 합계 142건 @everyone", {
    fetchImpl: async (url, options) => {
      assert.equal(new URL(url).searchParams.get("wait"), "true");
      assert.equal(options.method, "POST");
      assert.equal(options.redirect, "error");
      assert.deepEqual(JSON.parse(options.body), { content: "주간 합계 142건 @everyone", allowed_mentions: { parse: [] } });
      assert.ok(options.signal instanceof AbortSignal);
      return Response.json({ id: "923456789012345678", content: "private statistics" });
    },
  });
  assert.deepEqual(result, { id: "923456789012345678" });
});

test("webhook rejects non-Discord destinations and invalid content without sending", async () => {
  for (const url of [
    "https://evil.example/api/webhooks/1/token",
    "https://discord.com.evil.example/api/webhooks/1/token",
    "http://discord.com/api/webhooks/1/token",
    "https://user:password@discord.com/api/webhooks/1/token",
    webhookURL + "#secret",
    webhookURL + "?thread_id=bad",
    webhookURL + "?unknown=secret",
  ]) {
    await assert.rejects(sendWebhook(url, "리포트", { fetchImpl: neverRead }), (error) => {
      assert.ok(error instanceof WebhookDeliveryError);
      assert.equal(error.delivery, "not_sent");
      assert.doesNotMatch(error.message, /secret|token|password/);
      return true;
    });
  }
  for (const content of ["", " ", "x".repeat(2001)]) {
    await assert.rejects(sendWebhook(webhookURL, content, { fetchImpl: neverRead }), { code: "INVALID_MESSAGE", delivery: "not_sent" });
  }
});

test("webhook classifies definite rejections and uncertain deliveries without retrying", async () => {
  for (const [status, delivery] of [[400, "not_sent"], [401, "not_sent"], [404, "not_sent"], [429, "not_sent"], [408, "unknown"], [500, "unknown"], [503, "unknown"]]) {
    let calls = 0;
    await assert.rejects(sendWebhook(webhookURL, "리포트", {
      fetchImpl: async () => {
        calls += 1;
        return new Response("secret response body", { status });
      },
    }), (error) => {
      assert.equal(error.delivery, delivery);
      assert.equal(error.httpStatus, status);
      assert.doesNotMatch(error.message, /secret|EXAMPLE_TOKEN/);
      return true;
    });
    assert.equal(calls, 1);
  }
});

test("webhook network errors and malformed success bodies preserve uncertainty, not raw errors", async () => {
  for (const fetchImpl of [
    async () => { throw new Error("failed POST " + webhookURL); },
    async () => new Response("invalid JSON"),
    async () => Response.json({ content: "missing-id" }),
    async () => new Response(null, { status: 204 }),
  ]) {
    await assert.rejects(sendWebhook(webhookURL, "리포트", { fetchImpl }), (error) => {
      assert.equal(error.delivery, "unknown");
      assert.equal(error.cause, undefined);
      assert.doesNotMatch(String(error), /EXAMPLE_TOKEN|discord\.com/);
      return true;
    });
  }
});
