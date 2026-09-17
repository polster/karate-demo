#!/usr/bin/env bash
# Stops and removes the NATS container started via scripts/nats-start.sh. Safe to call even if
# it isn't running. Used by `make nats-stop`, `scripts/nats-test.sh`.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker compose -f "$SCRIPT_DIR/../docker-compose.nats.yml" down
