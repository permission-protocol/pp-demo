# nemoclaw-pp-adapter

Node.js/TypeScript daemon that tails OpenShell deny logs, batches blocked egress attempts into Permission Protocol requests, receives approval callbacks, updates OpenShell network policy, and notifies the OpenClaw agent to retry.

## What it does

- Tails `openshell logs <sandbox> --follow`
- Parses `action=deny` log lines for `dst_host`, `dst_port`, and `binary`
- Debounces unique deny events over a 5 second window
- POSTs the batch to a Permission Protocol request endpoint
- Exposes a local approval webhook receiver
- Applies approved endpoints back into the OpenShell YAML policy
- Sends a system message to OpenClaw after policy injection

## Dummy PP endpoint

By default the adapter also starts a local dummy PP service on `127.0.0.1:8788`:

- `POST /dummy-pp/requests`

It immediately simulates an approval callback back into the adapter webhook, which lets you test the full flow without a real PP backend.

## Environment

- `OPENSHELL_SANDBOX_NAME` default `nemoclaw`
- `BATCH_WINDOW_MS` default `5000`
- `PP_REQUEST_URL` default `http://127.0.0.1:8788/dummy-pp/requests`
- `PP_WEBHOOK_PORT` default `8787`
- `PP_WEBHOOK_PATH` default `/webhooks/permission-protocol`
- `PP_WEBHOOK_SECRET` default `local-dev-secret`
- `DUMMY_PP_PORT` default `8788`
- `DUMMY_PP_AUTO_APPROVE_MS` default `1000`
- `OPENCLAW_MESSAGE_URL` default `http://127.0.0.1:3000/api/message`
- `OPENCLAW_SESSION_ID` optional
- `USE_DUMMY_PP` default `true`

## Commands

- `npm run build`
- `npm run lint`
- `npm run typecheck`
- `npm test`
- `npm run verify`
