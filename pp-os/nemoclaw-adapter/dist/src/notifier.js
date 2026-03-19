import { postJson } from "./http.js";
export async function notifyAgent(messageUrl, payload) {
    await postJson(messageUrl, payload);
}


//# sourceURL=/Users/moltbot/.openclaw/workspace/pp-os/nemoclaw-adapter/src/notifier.ts