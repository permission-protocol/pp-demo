import { readdir } from "node:fs/promises";
import path from "node:path";
import { spawn } from "node:child_process";

const distDir = path.join(process.cwd(), "dist");

function runNodeCheck(filePath) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, ["--check", filePath], {
      stdio: "inherit",
    });
    child.on("exit", (code) => {
      if (code === 0) {
        resolve();
        return;
      }

      reject(new Error(`node --check failed for ${filePath}`));
    });
  });
}

async function collectJsFiles(dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  const files = [];

  for (const entry of entries) {
    const entryPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...(await collectJsFiles(entryPath)));
      continue;
    }

    if (entry.name.endsWith(".js")) {
      files.push(entryPath);
    }
  }

  return files;
}

await new Promise((resolve, reject) => {
  const child = spawn(process.execPath, ["scripts/build.mjs"], { stdio: "inherit" });
  child.on("exit", (code) => {
    if (code === 0) {
      resolve(undefined);
      return;
    }

    reject(new Error("build failed"));
  });
});

const files = await collectJsFiles(distDir);
for (const file of files) {
  await runNodeCheck(file);
}

console.log(`lint passed for ${files.length} files`);
