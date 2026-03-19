import { loadConfig } from "./config.js";
import { startDummyPpServer } from "./dummy-server.js";
import { PermissionProtocolAdapter } from "./adapter.js";

async function main(): Promise<void> {
  const config = loadConfig();
  const adapter = new PermissionProtocolAdapter(config);

  adapter.startWebhookServer();

  if (config.useDummyPp) {
    startDummyPpServer(config);
  }

  adapter.startLogTail();
}

main().catch((error: unknown) => {
  console.error("adapter failed to start", error);
  process.exitCode = 1;
});
