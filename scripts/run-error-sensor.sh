#!/usr/bin/env bash
set -e

# Node execution of the compiled TS orchestrator
# We use tsx since this is a dev/test stub environment
npx tsx src/crons/error-sensor/index.ts
