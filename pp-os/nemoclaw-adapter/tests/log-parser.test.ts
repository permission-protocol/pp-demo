import test from "node:test";
import assert from "node:assert/strict";

import { parseDeniedConnection } from "../src/log-parser.js";

test("parseDeniedConnection extracts deny event fields", () => {
  const line =
    "[1773954645.896] [sandbox] [INFO ] [openshell_sandbox::proxy] CONNECT action=deny ancestors=/usr/bin/bash binary=/usr/bin/curl binary_pid=6304 cmdline=/bin/bash dst_host=example.com dst_port=443 engine=opa reason=endpoint example.com:443 not in policy";
  const parsed = parseDeniedConnection(line);

  assert.ok(parsed);
  assert.equal(parsed.host, "example.com");
  assert.equal(parsed.port, 443);
  assert.equal(parsed.binary, "/usr/bin/curl");
});
