#!/usr/bin/env bash
# Starts a plain NATS server as a Docker container (see docker-compose.nats.yml), waiting until
# it reports healthy. No local image to build - this pulls the upstream nats image directly.
# Safe to call repeatedly. Used by `make nats-start`, `scripts/nats-test.sh`.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "starting NATS via docker compose ..."
docker compose -f "$SCRIPT_DIR/../docker-compose.nats.yml" up -d --wait
