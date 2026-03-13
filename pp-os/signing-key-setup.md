# Signing Key Setup for PP App

## What
Set `PP_SIGNING_PRIVATE_KEY` on Render to fix the "Automatic verification did not pass" / RECEIPT_NOT_FOUND error.

## Steps
1. Go to: https://dashboard.render.com/web/srv-d5gl2llactks73fp7rr0/settings
2. Under Environment → Add env var:
   - Key: `PP_SIGNING_PRIVATE_KEY`
   - Value: (read from `~/.openclaw/secrets/pp-signing-key.txt`)
3. `PP_SIGNING_KEY_ID` is already set to `pp_key_348f56d61d0deab4`
4. `PP_SIGNING_MODE` defaults to `required`

## Note
The key was generated on 2026-03-12 using `openssl rand -base64 32`.
This is a new key — old receipts signed with the lost key will remain unverifiable.
New receipts from this point forward will be properly signed and verifiable.
