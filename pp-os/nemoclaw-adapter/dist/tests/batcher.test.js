import test from "node:test";
import assert from "node:assert/strict";
import { DebouncedBatcher } from "../src/batcher.js";
test("DebouncedBatcher deduplicates entries within the window", async ()=>{
    const batches = [];
    const batcher = new DebouncedBatcher(5, async (entries)=>{
        batches.push(entries.map((entry)=>`${entry.host}:${entry.port}:${entry.binary}`));
    });
    batcher.add({
        host: "registry.npmjs.org",
        port: 443,
        binary: "/usr/bin/npm",
        rawLine: "a",
        detectedAt: new Date().toISOString()
    });
    batcher.add({
        host: "registry.npmjs.org",
        port: 443,
        binary: "/usr/bin/npm",
        rawLine: "b",
        detectedAt: new Date().toISOString()
    });
    await new Promise((resolve)=>setTimeout(resolve, 20));
    assert.equal(batches.length, 1);
    assert.equal(batches[0].length, 1);
});


//# sourceURL=/Users/moltbot/.openclaw/workspace/pp-os/nemoclaw-adapter/tests/batcher.test.ts