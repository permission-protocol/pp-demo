import { loadConfig } from "./config.js";
import { startDummyPpServer } from "./dummy-server.js";
import { PermissionProtocolAdapter } from "./adapter.js";
async function main() {
    const config = loadConfig();
    const adapter = new PermissionProtocolAdapter(config);
    adapter.startWebhookServer();
    if (config.useDummyPp) {
        startDummyPpServer(config);
    }
    adapter.startLogTail();
}
main().catch((error)=>{
    console.error("adapter failed to start", error);
    process.exitCode = 1;
});


//# sourceURL=/Users/moltbot/.openclaw/workspace/pp-os/nemoclaw-adapter/src/index.ts