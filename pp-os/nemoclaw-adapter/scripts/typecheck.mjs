import { spawn } from "node:child_process";

const child = spawn(process.execPath, ["scripts/build.mjs"], { stdio: "inherit" });

await new Promise((resolve, reject) => {
  child.on("exit", (code) => {
    if (code === 0) {
      resolve(undefined);
      return;
    }

    reject(new Error("build failed"));
  });
});

console.log("typecheck surrogate passed: sources transpile cleanly with Node stripTypeScriptTypes");
