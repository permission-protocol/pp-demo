import { mkdir, readdir, readFile, rm, writeFile } from "node:fs/promises";
import path from "node:path";
import { stripTypeScriptTypes } from "node:module";

const projectRoot = process.cwd();
const outDir = path.join(projectRoot, "dist");
const sourceDirs = ["src", "tests"];

async function ensureCleanDist() {
  await rm(outDir, { recursive: true, force: true });
  await mkdir(outDir, { recursive: true });
}

async function transpileFile(inputPath, outputPath) {
  const source = await readFile(inputPath, "utf8");
  const compiled = stripTypeScriptTypes(source, {
    mode: "transform",
    sourceUrl: inputPath,
  });
  await mkdir(path.dirname(outputPath), { recursive: true });
  await writeFile(outputPath, compiled, "utf8");
}

async function walkAndCompile(relativeDir) {
  const absoluteDir = path.join(projectRoot, relativeDir);
  const entries = await readdir(absoluteDir, { withFileTypes: true });

  for (const entry of entries) {
    const entryPath = path.join(absoluteDir, entry.name);
    if (entry.isDirectory()) {
      await walkAndCompile(path.join(relativeDir, entry.name));
      continue;
    }

    if (!entry.name.endsWith(".ts")) {
      continue;
    }

    const outputRelativePath = path.join(
      relativeDir,
      entry.name.replace(/\.ts$/, ".js"),
    );
    await transpileFile(entryPath, path.join(outDir, outputRelativePath));
  }
}

await ensureCleanDist();

for (const dir of sourceDirs) {
  await walkAndCompile(dir);
}

console.log("built dist/");
