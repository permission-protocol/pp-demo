import { createRequire } from "node:module";
import path from "node:path";
import { promises as fs } from "node:fs";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

import { resolveWorkspaceYamlModule } from "./config.js";
import type { DeniedConnection } from "./types.js";

const execFileAsync = promisify(execFile);

interface NetworkPolicyEndpoint {
  host: string;
  port: number;
  access: string;
}

interface NetworkPolicyEntry {
  name: string;
  endpoints: NetworkPolicyEndpoint[];
  binaries: Array<{ path: string }>;
}

interface PolicyDocument {
  network_policies?: Record<string, NetworkPolicyEntry>;
  [key: string]: unknown;
}

async function loadYamlModule(): Promise<{
  parse: (input: string) => PolicyDocument;
  stringify: (input: PolicyDocument) => string;
}> {
  const require = createRequire(import.meta.url);
  return require(resolveWorkspaceYamlModule());
}

function buildPolicyName(): string {
  return `pp_approved_batch_${Date.now()}`;
}

function toPolicyEntry(entries: DeniedConnection[]): NetworkPolicyEntry {
  const uniqueBinaries = [...new Set(entries.map((entry) => entry.binary))];

  return {
    name: buildPolicyName(),
    endpoints: entries.map((entry) => ({
      host: entry.host,
      port: entry.port,
      access: "full",
    })),
    binaries: uniqueBinaries.map((binary) => ({ path: binary })),
  };
}

export async function injectApprovedPolicy(
  sandboxName: string,
  entries: DeniedConnection[],
): Promise<{ policyPath: string; applied: boolean }> {
  const yaml = await loadYamlModule();
  const { stdout } = await execFileAsync("openshell", ["policy", "get", sandboxName, "--full"], {
    maxBuffer: 1024 * 1024 * 10,
  });

  const currentPolicy = yaml.parse(stdout) ?? {};
  const policy = currentPolicy as PolicyDocument;
  const policyName = buildPolicyName();

  policy.network_policies ??= {};
  policy.network_policies[policyName] = {
    ...toPolicyEntry(entries),
    name: policyName,
  };

  const policyPath = path.resolve(process.cwd(), `${policyName}.yaml`);
  await fs.writeFile(policyPath, yaml.stringify(policy), "utf8");

  await execFileAsync("openshell", ["policy", "set", sandboxName, "--policy", policyPath], {
    maxBuffer: 1024 * 1024 * 10,
  });

  return { policyPath, applied: true };
}
