#!/usr/bin/env bash
# Builds (if needed) and starts the bundled mock API as a Docker container (see
# docker-compose.yml) on a fixed port, waiting until it reports healthy. Safe to call
# repeatedly - an already-running, up-to-date container is left alone. Used by
# `make mock-start`, `scripts/functional-test.sh` and `scripts/load-test.sh`.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "starting mock API via docker compose ..."
docker compose -f "$SCRIPT_DIR/../docker-compose.yml" up -d --build --wait
