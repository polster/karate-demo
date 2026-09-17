#!/usr/bin/env bash
# Stops and removes the mock API container started via scripts/mock-start.sh. Safe to call
# even if it isn't running. Used by `make mock-stop`, `scripts/functional-test.sh` and
# scripts/load-test.sh.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker compose -f "$SCRIPT_DIR/../docker-compose.yml" down
