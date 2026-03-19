import path from "node:path";

export interface AdapterConfig {
  sandboxName: string;
  debounceMs: number;
  ppRequestUrl: string;
  ppWebhookPort: number;
  ppWebhookPath: string;
  ppWebhookSecret: string;
  dummyPpPort: number;
  dummyPpAutoApproveMs: number;
  openClawMessageUrl: string;
  openClawSessionId?: string;
  useDummyPp: boolean;
}

function toInt(value: string | undefined, fallback: number): number {
  if (!value) {
    return fallback;
  }

  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function defaultWebhookUrl(port: number, route: string): string {
  return `http://127.0.0.1:${port}${route}`;
}

export function loadConfig(env: NodeJS.ProcessEnv = process.env): AdapterConfig {
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
    useDummyPp,
  };
}

export function resolveWorkspaceYamlModule(): string {
  return path.resolve(
    process.cwd(),
    "..",
    "permission-protocol-brand-app",
    "node_modules",
    "cosmiconfig",
    "node_modules",
    "yaml",
    "dist",
    "index.js",
  );
}

export function approvalWebhookUrl(config: AdapterConfig): string {
  return defaultWebhookUrl(config.ppWebhookPort, config.ppWebhookPath);
}
