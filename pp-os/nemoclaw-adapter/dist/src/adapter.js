import http from "node:http";
import crypto from "node:crypto";
import { spawn } from "node:child_process";
import readline from "node:readline";
import { approvalWebhookUrl } from "./config.js";
import { DebouncedBatcher } from "./batcher.js";
import { postJson } from "./http.js";
import { parseDeniedConnection } from "./log-parser.js";
import { notifyAgent } from "./notifier.js";
import { injectApprovedPolicy } from "./policy.js";
function jsonResponse(response, status, payload) {
    response.writeHead(status, {
        "content-type": "application/json"
    });
    response.end(JSON.stringify(payload));
}
export class PermissionProtocolAdapter {
    #config;
    #batcher;
    constructor(config){
        this.#config = config;
        this.#batcher = new DebouncedBatcher(config.debounceMs, async (entries)=>{
            const batch = {
                requestId: crypto.randomUUID(),
                sandboxName: this.#config.sandboxName,
                createdAt: new Date().toISOString(),
                entries
            };
            await postJson(this.#config.ppRequestUrl, {
                ...batch,
                context: "The NemoClaw agent attempted outbound connections blocked by OpenShell and needs egress approval.",
                callbackUrl: approvalWebhookUrl(this.#config)
            });
            console.log(`submitted PP request ${batch.requestId} for ${entries.map((entry)=>`${entry.host}:${entry.port}`).join(", ")}`);
        });
    }
    startLogTail() {
        const child = spawn("openshell", [
            "logs",
            this.#config.sandboxName,
            "--follow"
        ], {
            stdio: [
                "ignore",
                "pipe",
                "inherit"
            ]
        });
        child.on("exit", (code, signal)=>{
            console.error(`openshell logs exited with code=${code ?? "null"} signal=${signal ?? "null"}`);
        });
        const lineReader = readline.createInterface({
            input: child.stdout
        });
        lineReader.on("line", (line)=>{
            const entry = parseDeniedConnection(line);
            if (entry) {
                this.#batcher.add(entry);
            }
        });
    }
    startWebhookServer() {
        const server = http.createServer(async (request, response)=>{
            if (request.method !== "POST" || request.url !== this.#config.ppWebhookPath) {
                jsonResponse(response, 404, {
                    error: "not_found"
                });
                return;
            }
            const chunks = [];
            for await (const chunk of request){
                chunks.push(Buffer.from(chunk));
            }
            const body = Buffer.concat(chunks).toString("utf8");
            const signature = request.headers["x-pp-signature"];
            if (signature !== this.#config.ppWebhookSecret) {
                jsonResponse(response, 401, {
                    error: "invalid_signature"
                });
                return;
            }
            const receipt = JSON.parse(body);
            await this.#handleReceipt(receipt);
            jsonResponse(response, 200, {
                ok: true
            });
        });
        server.listen(this.#config.ppWebhookPort, "127.0.0.1", ()=>{
            console.log(`approval webhook listening on ${approvalWebhookUrl(this.#config)}`);
        });
        return server;
    }
    async #handleReceipt(receipt) {
        if (!receipt.approved) {
            console.log(`PP request ${receipt.requestId} denied`);
            return;
        }
        await injectApprovedPolicy(this.#config.sandboxName, receipt.entries);
        await notifyAgent(this.#config.openClawMessageUrl, {
            sessionId: this.#config.openClawSessionId,
            message: "System: Your requested outbound network endpoints have been approved by the administrator and the sandbox policy has been updated. You may now retry your last command."
        });
        console.log(`PP request ${receipt.requestId} approved and policy applied`);
    }
}


//# sourceURL=/Users/moltbot/.openclaw/workspace/pp-os/nemoclaw-adapter/src/adapter.ts