#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: ./scripts/run-hosted-smoke-test.sh https://your-hosted-backend.example.com" >&2
  exit 1
fi

BACKEND_BASE_URL="$1" npm run smoke:hosted
