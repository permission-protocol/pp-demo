import { createRequire } from "node:module";
import path from "node:path";
import { promises as fs } from "node:fs";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { resolveWorkspaceYamlModule } from "./config.js";
const execFileAsync = promisify(execFile);
async function loadYamlModule() {
    const require = createRequire(import.meta.url);
    return require(resolveWorkspaceYamlModule());
}
function buildPolicyName() {
    return `pp_approved_batch_${Date.now()}`;
}
function toPolicyEntry(entries) {
    const uniqueBinaries = [
        ...new Set(entries.map((entry)=>entry.binary))
    ];
    return {
        name: buildPolicyName(),
        endpoints: entries.map((entry)=>({
                host: entry.host,
                port: entry.port,
                access: "full"
            })),
        binaries: uniqueBinaries.map((binary)=>({
                path: binary
            }))
    };
}
export async function injectApprovedPolicy(sandboxName, entries) {
    const yaml = await loadYamlModule();
    const { stdout } = await execFileAsync("openshell", [
        "policy",
        "get",
        sandboxName,
        "--full"
    ], {
        maxBuffer: 1024 * 1024 * 10
    });
    const currentPolicy = yaml.parse(stdout) ?? {};
    const policy = currentPolicy;
    const policyName = buildPolicyName();
    policy.network_policies ??= {};
    policy.network_policies[policyName] = {
        ...toPolicyEntry(entries),
        name: policyName
    };
    const policyPath = path.resolve(process.cwd(), `${policyName}.yaml`);
    await fs.writeFile(policyPath, yaml.stringify(policy), "utf8");
    await execFileAsync("openshell", [
        "policy",
        "set",
        sandboxName,
        "--policy",
        policyPath
    ], {
        maxBuffer: 1024 * 1024 * 10
    });
    return {
        policyPath,
        applied: true
    };
}


//# sourceURL=/Users/moltbot/.openclaw/workspace/pp-os/nemoclaw-adapter/src/policy.ts