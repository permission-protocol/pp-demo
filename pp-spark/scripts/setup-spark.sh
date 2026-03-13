#!/bin/bash
# PP Signer Gap Engine — Spark Setup
# Run this ON the DGX Spark after pulling qwen3:32b
#
# Prerequisites:
#   ollama pull qwen3:32b
#
# Usage:
#   scp -r pp-spark/ spark:/home/user/pp-spark/
#   ssh spark
#   bash pp-spark/scripts/setup-spark.sh

set -e

SPARK_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "=== PP Signer Gap Engine — Spark Setup ==="
echo "Directory: $SPARK_DIR"

# Check Ollama
echo ""
echo "Checking Ollama..."
if ! command -v ollama &>/dev/null; then
    echo "[ERROR] Ollama not found. Install it first."
    exit 1
fi

# Check model
echo "Checking for qwen3:32b..."
if ollama list | grep -q "qwen3:32b"; then
    echo "[OK] qwen3:32b is available"
else
    echo "[WARN] qwen3:32b not found. Pull it:"
    echo "  ollama pull qwen3:32b"
    exit 1
fi

# Check Python
echo ""
echo "Checking Python..."
python3 --version

# Install requests if needed
if ! python3 -c "import requests" 2>/dev/null; then
    echo "Installing requests..."
    pip3 install requests
fi

# Quick model test
echo ""
echo "Testing model connection..."
RESPONSE=$(python3 -c "
import requests, json
r = requests.post('http://localhost:11434/api/generate', json={
    'model': 'qwen3:32b',
    'prompt': 'Return only this JSON: {\"status\": \"ok\"}',
    'stream': False,
    'options': {'temperature': 0, 'num_predict': 50}
}, timeout=120)
print(r.json().get('response', 'FAILED')[:200])
")
echo "Model response: $RESPONSE"

# Run ingest
echo ""
echo "Running corpus ingest..."
cd "$SPARK_DIR"
python3 scripts/ingest.py

echo ""
echo "=== SETUP COMPLETE ==="
echo ""
echo "To run the pipeline:"
echo "  cd $SPARK_DIR"
echo "  python3 scripts/pipeline.py"
echo ""
echo "To render a daily packet:"
echo "  python3 scripts/packet.py"
echo ""
echo "To set up cron (every 6h pipeline, daily packet):"
echo "  crontab -e"
echo "  # Add:"
echo "  0 */6 * * * cd $SPARK_DIR && python3 scripts/pipeline.py >> logs/pipeline.log 2>&1"
echo "  0 13 * * * cd $SPARK_DIR && python3 scripts/packet.py >> logs/packet.log 2>&1"
