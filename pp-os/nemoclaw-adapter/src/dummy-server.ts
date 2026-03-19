import http from "node:http";
import crypto from "node:crypto";

import { approvalWebhookUrl, type AdapterConfig } from "./config.js";
import { postJson } from "./http.js";
import type { ApprovalBatch, PpApprovalReceipt } from "./types.js";

function jsonResponse(response: http.ServerResponse, status: number, payload: unknown): void {
  response.writeHead(status, { "content-type": "application/json" });
  response.end(JSON.stringify(payload));
}

export function startDummyPpServer(config: AdapterConfig): http.Server {
  const server = http.createServer(async (request, response) => {
    if (request.method !== "POST" || request.url !== "/dummy-pp/requests") {
      jsonResponse(response, 404, { error: "not_found" });
      return;
    }

    const chunks: Buffer[] = [];
    for await (const chunk of request) {
      chunks.push(Buffer.from(chunk));
    }

    const batch = JSON.parse(Buffer.concat(chunks).toString("utf8")) as ApprovalBatch;
    const requestId = batch.requestId ?? crypto.randomUUID();

    jsonResponse(response, 202, {
      requestId,
      status: "queued",
      approvalWebhook: approvalWebhookUrl(config),
    });

    setTimeout(() => {
      const receipt: PpApprovalReceipt = {
        requestId,
        approved: true,
        receiptId: crypto.randomUUID(),
        approvedAt: new Date().toISOString(),
        entries: batch.entries,
        sandboxName: batch.sandboxName,
        signature: config.ppWebhookSecret,
      };

      void postJson(approvalWebhookUrl(config), receipt, {
        "x-pp-signature": config.ppWebhookSecret,
      }).catch((error: unknown) => {
        console.error("dummy approval callback failed", error);
      });
    }, config.dummyPpAutoApproveMs);
  });

  server.listen(config.dummyPpPort, "127.0.0.1", () => {
    console.log(`dummy PP server listening on http://127.0.0.1:${config.dummyPpPort}`);
  });

  return server;
}
