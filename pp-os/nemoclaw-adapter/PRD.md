# PRD: Permission Protocol Adapter for NVIDIA NemoClaw

## Objective
Build a lightweight Node.js daemon (`nemoclaw-pp-adapter`) that bridges NVIDIA's OpenShell sandbox environment (used by NemoClaw) with the Permission Protocol (PP) governance layer. 

The adapter will autonomously monitor a local NemoClaw sandbox for blocked outbound network requests, batch them, escalate them to the Permission Protocol API for human approval, and dynamically update the sandbox policy once approved, followed by notifying the agent to retry its failed command.

## Background & Architecture
NVIDIA NemoClaw runs an OpenClaw agent inside OpenShell, an eBPF/Landlock sandbox that enforces a strict default-deny network policy. 

When the agent attempts to reach an unapproved endpoint (e.g., `curl https://example.com`), OpenShell drops the connection immediately (`HTTP 403 Forbidden` / `ECONNREFUSED` in 8ms) and logs the denial. 

Normally, an operator at the local terminal uses an interactive TUI to approve these requests. We are replacing this local TUI with remote, asynchronous governance via Permission Protocol.

## Core Workflows

### 1. Monitoring & Interception
- The adapter must continuously tail the logs of a target OpenShell sandbox using the CLI command:
  ```bash
  openshell logs <sandbox-name> --follow
  ```
- It must parse the stdout stream specifically for `action=deny` events. Example log line:
  ```
  [1773954645.896] [sandbox] [INFO ] [openshell_sandbox::proxy] CONNECT action=deny ancestors=/usr/bin/bash -> /opt/openshell/bin/openshell-sandbox binary=/usr/bin/curl binary_pid=6304 cmdline=/bin/bash dst_host=example.com dst_port=443 engine=opa policy=- proxy_addr=10.200.0.1:3128 reason=endpoint example.com:443 not in policy ...
  ```
- **Extraction:** Extract the `dst_host`, `dst_port`, and `binary` from these denial logs.

### 2. Batching (The "npm install" Problem)
- If an agent runs a command like `npm install`, it may attempt to hit dozens of blocked endpoints in a single second.
- The adapter must implement a **Debounce/Batching Window** (e.g., 5 seconds). 
- All unique blocked hosts within that window should be grouped into a single Permission Protocol deploy request to prevent notification spam.

### 3. Escalation to Permission Protocol
- Once the batch window closes, the adapter must create a new deploy request via the PP API:
  - **Endpoint:** `POST https://hooks.permissionprotocol.com/api/v1/requests` (or standard webhook ingestion).
  - **Payload:** Must include the list of blocked hosts, ports, and the binary that initiated the request.
  - **Context:** Explain that the agent is requesting egress access to these domains.

### 4. Polling & Resolution
- The adapter must poll the PP API (or expose a local webhook receiver) to await the cryptographically signed approval receipt.
- While waiting, the agent's original command will have failed locally. The adapter just waits for human resolution.

### 5. Policy Injection
- Upon receiving a positive approval receipt from PP, the adapter must dynamically update the OpenShell policy.
- **Read:** Fetch the current active policy as YAML:
  ```bash
  openshell policy get <sandbox-name> --full > current.yaml
  ```
- **Edit:** Parse the YAML and inject a new block under `network_policies`. E.g.,
  ```yaml
  network_policies:
    pp_approved_batch_<timestamp>:
      name: pp_approved_batch_<timestamp>
      endpoints:
        - host: example.com
          port: 443
          access: full
      binaries:
        - { path: /usr/bin/curl }
  ```
- **Apply:** Push the modified policy back to the live sandbox:
  ```bash
  openshell policy set <sandbox-name> --policy current.yaml
  ```

### 6. Agent Re-engagement
- Because OpenShell drops connections immediately, the agent's original task failed and the agent is now idle.
- The adapter must notify the OpenClaw agent that its requested network access has been granted so it knows to try again.
- **Action:** Inject a system message into the OpenClaw session (via the local OpenClaw Gateway `message` API or by creating a one-off job via the `cron` API):
  - *Message:* "System: Your requested outbound network endpoints have been approved by the administrator and the sandbox policy has been updated. You may now retry your last command."

## Technical Constraints
- **Language:** Node.js (TypeScript preferred) to easily run alongside the existing OpenClaw/Node toolchain.
- **Dependencies:** `yaml` (for parsing/editing policy), standard `child_process.spawn` for CLI interaction.
- **Robustness:** Do not attempt to reverse-engineer NVIDIA's internal gRPC APIs or sockets. Strictly interface with OpenShell via its documented CLI (`openshell logs`, `openshell policy get`, `openshell policy set`).
- **Resilience:** The log parser regex must be flexible enough to handle minor formatting changes in OpenShell updates.

## Success Criteria
1. An agent running inside NemoClaw attempts a blocked `curl`.
2. The command fails immediately.
3. The adapter batches the request and escalates it to PP.
4. The human approves via the PP Dashboard.
5. The adapter updates the OpenShell policy successfully.
6. The adapter injects a system message telling the agent to retry.
7. The agent retries the `curl` and it succeeds.