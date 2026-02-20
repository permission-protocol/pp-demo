# Setting Up Your Fork

Want to try Permission Protocol on your own repo? Here's how:

## 1. Create a PP Account

Go to [app.permissionprotocol.com](https://app.permissionprotocol.com) and sign up.

## 2. Connect GitHub

In the PP dashboard:
1. Go to Settings → GitHub
2. Click "Connect GitHub"
3. Use a **Classic Personal Access Token** with `repo` scope
4. Grant access to your fork's organization

## 3. Add Your Repo

1. Go to Settings → Repositories
2. Click "Add Repository"
3. Select your fork of pp-demo

## 4. Get API Keys

1. Go to Settings → API Keys
2. Create a new API key (copy it immediately)
3. Create a "Request Create Token" for auto-creating deploy requests

## 5. Add GitHub Secrets

In your fork's Settings → Secrets → Actions:

| Secret | Value |
|--------|-------|
| `PP_BASE_URL` | `https://app.permissionprotocol.com` |
| `PP_API_KEY` | Your API key from step 4 |
| `PP_REQUEST_CREATE_TOKEN` | Your request create token from step 4 |

## 6. Test It

1. Create a branch
2. Edit `deploy/config.yml`
3. Open a PR
4. Watch the gate fail
5. Click the approval link
6. Approve in PP
7. Re-run the workflow
8. Merge!

---

**Questions?** Open an issue or visit [permissionprotocol.com](https://permissionprotocol.com)
