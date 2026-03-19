import path from "node:path";
function toInt(value, fallback) {
    if (!value) {
        return fallback;
    }
    const parsed = Number.parseInt(value, 10);
    return Number.isFinite(parsed) ? parsed : fallback;
}
function defaultWebhookUrl(port, route) {
    return `http://127.0.0.1:${port}${route}`;
}
export function loadConfig(env = process.env) {
    const ppWebhookPort = toInt(env.PP_WEBHOOK_PORT, 8787);
    const ppWebhookPath = env.PP_WEBHOOK_PATH ?? "/webhooks/permission-protocol";
    const dummyPpPort = toInt(env.DUMMY_PP_PORT, 8788);
    const useDummyPp = (env.USE_DUMMY_PP ?? "true").toLowerCase() !== "false";
    return {
        sandboxName: env.OPENSHELL_SANDBOX_NAME ?? "nemoclaw",
        debounceMs: toInt(env.BATCH_WINDOW_MS, 5_000),
        ppRequestUrl: env.PP_REQUEST_URL ?? `http://127.0.0.1:${dummyPpPort}/dummy-pp/requests`,
        ppWebhookPort,
        ppWebhookPath,
        ppWebhookSecret: env.PP_WEBHOOK_SECRET ?? "local-dev-secret",
        dummyPpPort,
        dummyPpAutoApproveMs: toInt(env.DUMMY_PP_AUTO_APPROVE_MS, 1_000),
        openClawMessageUrl: env.OPENCLAW_MESSAGE_URL ?? "http://127.0.0.1:3000/api/message",
        openClawSessionId: env.OPENCLAW_SESSION_ID,
        useDummyPp
    };
}
export function resolveWorkspaceYamlModule() {
    return path.resolve(process.cwd(), "..", "permission-protocol-brand-app", "node_modules", "cosmiconfig", "node_modules", "yaml", "dist", "index.js");
}
export function approvalWebhookUrl(config) {
    return defaultWebhookUrl(config.ppWebhookPort, config.ppWebhookPath);
}


//# sourceURL=/Users/moltbot/.openclaw/workspace/pp-os/nemoclaw-adapter/src/config.ts