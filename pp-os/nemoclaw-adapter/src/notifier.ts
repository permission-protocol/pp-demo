import { postJson } from "./http.js";

export interface AgentNotificationPayload {
  sessionId?: string;
  message: string;
}

export async function notifyAgent(
  messageUrl: string,
  payload: AgentNotificationPayload,
): Promise<void> {
  await postJson(messageUrl, payload);
}
