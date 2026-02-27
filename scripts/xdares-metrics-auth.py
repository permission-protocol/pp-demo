#!/usr/bin/env python3
"""
One-time OAuth setup for Xdares analytics APIs.
Gets refresh token for GA4 + Search Console access.
Run once, then metrics-collect.sh uses the token automatically.
"""
import json, os, sys, urllib.request, urllib.parse, http.server, threading

CREDS_PATH = os.path.expanduser("~/Library/Application Support/gogcli/credentials.json")
TOKEN_PATH = os.path.expanduser("~/.openclaw/secrets/google-analytics-token.json")

SCOPES = [
    "https://www.googleapis.com/auth/analytics.readonly",
    "https://www.googleapis.com/auth/webmasters.readonly",
]

with open(CREDS_PATH) as f:
    creds = json.load(f)

CLIENT_ID = creds["client_id"]
CLIENT_SECRET = creds["client_secret"]

# Build auth URL
params = urllib.parse.urlencode({
    "client_id": CLIENT_ID,
    "redirect_uri": "http://localhost:8765",
    "response_type": "code",
    "scope": " ".join(SCOPES),
    "access_type": "offline",
    "prompt": "consent",
})
auth_url = f"https://accounts.google.com/o/oauth2/auth?{params}"

print(f"\n🔐 Open this URL in your browser:\n\n{auth_url}\n")
print("Waiting for OAuth callback on localhost:8765...")

# Simple callback server
auth_code = {"value": None}
class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        qs = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
        if "code" in qs:
            auth_code["value"] = qs["code"][0]
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"<h1>Success! You can close this tab.</h1>")
        else:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"No code received")
    def log_message(self, *args): pass

server = http.server.HTTPServer(("localhost", 8765), Handler)
server.handle_request()

if not auth_code["value"]:
    print("❌ No auth code received")
    sys.exit(1)

# Exchange code for tokens
data = urllib.parse.urlencode({
    "code": auth_code["value"],
    "client_id": CLIENT_ID,
    "client_secret": CLIENT_SECRET,
    "redirect_uri": "http://localhost:8765",
    "grant_type": "authorization_code",
}).encode()

req = urllib.request.Request("https://oauth2.googleapis.com/token", data=data, method="POST")
req.add_header("Content-Type", "application/x-www-form-urlencoded")
resp = urllib.request.urlopen(req)
tokens = json.loads(resp.read())

# Save with client creds for refresh
tokens["client_id"] = CLIENT_ID
tokens["client_secret"] = CLIENT_SECRET

os.makedirs(os.path.dirname(TOKEN_PATH), exist_ok=True)
with open(TOKEN_PATH, "w") as f:
    json.dump(tokens, f, indent=2)
os.chmod(TOKEN_PATH, 0o600)

print(f"\n✅ Token saved to {TOKEN_PATH}")
print(f"   Scopes: {tokens.get('scope', 'unknown')}")
print(f"   Has refresh_token: {'refresh_token' in tokens}")
