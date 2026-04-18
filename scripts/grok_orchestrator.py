import os
import sys
import subprocess
import time
import argparse
import requests
from dotenv import load_dotenv
import permission_protocol as pp

load_dotenv()

XAI_API_KEY = os.getenv("XAI_API_KEY")
OPENCLAW_TOKEN = os.getenv("OPENCLAW_TOKEN")
PP_API_KEY = os.getenv("PP_API_KEY")

OPENCLAW_URL = "http://localhost:18789/v1/chat/completions"
GROK_URL = "https://api.x.ai/v1/chat/completions"

headers_grok = {"Authorization": f"Bearer {XAI_API_KEY}", "Content-Type": "application/json"}
headers_openclaw = {
    "Authorization": f"Bearer {OPENCLAW_TOKEN}",
    "Content-Type": "application/json"
}

MODEL_GROK = "grok-4"
MODEL_OPENCLAW = "agent:main"

pp.configure(api_key=PP_API_KEY, base_url="https://company-os-web.onrender.com")

def call_api(url, headers, model, messages, timeout=900):
    payload = {
        "model": model,
        "messages": messages,
        "temperature": 0.7,
        "max_tokens": 4096
    }
    r = requests.post(url, headers=headers, json=payload, timeout=timeout)
    r.raise_for_status()
    return r.json()["choices"][0]["message"]["content"]

def run_doctor():
    print("🚨 Running openclaw doctor...")
    try:
        result = subprocess.run(["openclaw", "doctor"], capture_output=True, text=True, timeout=30)
        print(result.stdout)
    except Exception as e:
        print(f"Doctor failed: {e}")

def main():
    parser = argparse.ArgumentParser(description="Grok ↔ OpenClaw Orchestrator")
    parser.add_argument("--skip-checkpoint2", action="store_true", help="Skip PP approval for sending Charles's reply back to Grok")
    parser.add_argument("--max-iterations", type=int, default=50, help="Maximum number of loop iterations")
    args = parser.parse_args()

    print(f"🚀 Grok ↔ OpenClaw Orchestrator (agent:main + Permission Protocol mobile approvals)")
    print(f"⚙️  Settings: Max Iterations={args.max_iterations}, Skip Checkpoint 2={args.skip_checkpoint2}")
    
    # --- CONTEXT INJECTION FOR GROK ---
    print("🧠 Loading OpenClaw active context for Grok...")
    try:
        with open("/Users/moltbot/.openclaw/workspace/ACTIVE_CONTEXT.md", "r") as f:
            active_context = f.read()
    except Exception as e:
        active_context = "Context unavailable."

    system_prompt = (
        "You are SuperGrok, acting as the high-level orchestrator and strategist for an OpenClaw AI agent named Charles Goldberg. "
        "Charles executes the actual work (he has access to the local filesystem, terminal, browser, and GitHub). "
        "Your job is to direct Charles, write prompts for him to execute, and review his output. "
        f"Here is Charles's current ACTIVE_CONTEXT:\n\n{active_context}\n\n"
        "When you reply, specify the exact message Charles should receive to advance these goals."
    )
    history_grok = [{"role": "system", "content": system_prompt}]
    # ----------------------------------

    print("📤 Sending handshake to agent:main...")
    handshake = "Grok orchestrator connected via agent:main with Permission Protocol human-in-the-loop approvals on Telegram. Single messages only — you have full memory/tools."
    try:
        call_api(OPENCLAW_URL, headers_openclaw, MODEL_OPENCLAW, [{"role": "user", "content": handshake}])
        print("✅ Connected. All approvals now go to your Telegram.\\n")
    except Exception as e:
        print(f"Failed to handshake with OpenClaw: {e}")

    iteration = 0
    try:
        while iteration < args.max_iterations:
            iteration += 1
            print(f"\\n--- Iteration {iteration}/{args.max_iterations} ---")
            
            try:
                user_input = input("Your command (or Enter to continue loop, 'quit'/'stop' to exit): ").strip()
            except KeyboardInterrupt:
                print("\\n🛑 Caught Ctrl+C. Gracefully exiting loop.")
                break

            if user_input.lower() in ["quit", "exit", "stop"]:
                print("🛑 Stopping orchestrator gracefully.")
                break

            if not user_input:
                user_input = "Review the active context and give Charles his next task."

            print("🤖 Grok is thinking...")
            grok_response = call_api(GROK_URL, headers_grok, MODEL_GROK, history_grok + [{"role": "user", "content": user_input}])

            print(f"\\n📤 Grok proposes:\\n{grok_response}\\n")

            print("⏳ Waiting for your Telegram approval (Checkpoint 1)...")
            try:
                receipt1 = pp.authorize(
                    action="send_to_openclaw",
                    resource="agent:main",
                    actor="grok-orchestrator",
                    metadata={"proposed_message_preview": grok_response[:800], "checkpoint": "1"},
                    wait=True,
                    timeout=900
                )
                if receipt1.status != "approved":
                    print(f"❌ Rejected (status: {receipt1.status}). Skipping...")
                    continue
            except Exception as e:
                print(f"Approval failed: {e}")
                continue

            print("📥 Sending to agent:main...")
            try:
                openclaw_reply = call_api(OPENCLAW_URL, headers_openclaw, MODEL_OPENCLAW, [{"role": "user", "content": grok_response}])
            except Exception as e:
                print(f"💥 {e}")
                run_doctor()
                continue

            print(f"\\n📬 OpenClaw responded:\\n{openclaw_reply}\\n")

            if not args.skip_checkpoint2:
                print("⏳ Waiting for your Telegram approval (Checkpoint 2)...")
                try:
                    receipt2 = pp.authorize(
                        action="feed_back_to_grok",
                        resource="agent:main",
                        actor="grok-orchestrator",
                        metadata={"openclaw_reply_preview": openclaw_reply[:800], "checkpoint": "2"},
                        wait=True,
                        timeout=900
                    )
                    if receipt2.status != "approved":
                        print(f"❌ Not feeding back (status: {receipt2.status}).")
                        continue
                except Exception as e:
                    print(f"Approval failed: {e}")
                    continue
            else:
                print("⏩ Skipping Checkpoint 2 (feed_back_to_grok) due to --skip-checkpoint2 flag.")

            history_grok.extend([
                {"role": "user", "content": grok_response},
                {"role": "assistant", "content": openclaw_reply}
            ])
            if len(history_grok) > 30:
                history_grok = [history_grok[0]] + history_grok[-29:]

            print("✅ Loop complete. Ready for next turn.")
            
        if iteration >= args.max_iterations:
            print(f"\\n🛑 Reached max iterations ({args.max_iterations}). Exiting to prevent token burn.")
            
    except KeyboardInterrupt:
        print("\\n🛑 Caught Ctrl+C. Gracefully exiting orchestrator.")
    finally:
        print("✅ Orchestrator shutdown complete.")

if __name__ == "__main__":
    main()
