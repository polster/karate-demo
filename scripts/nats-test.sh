#!/usr/bin/env bash
# Runs the NATS functional Karate tests (pub/sub + request/reply) against a NATS server running
# via Docker Compose: starts NATS, runs the tests, and always stops NATS afterwards, even if the
# tests fail. Used by `make test-nats`.
#
# Usage: scripts/nats-test.sh <karate.env>
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KARATE_ENV="${1:-dev}"
NATS_SERVER_URL="${NATS_SERVER_URL:-nats://localhost:4222}"

"$SCRIPT_DIR/nats-start.sh" || exit 1

mvn --batch-mode test -Dtest=demo.nats.TestNatsRunner -Dkarate.env="$KARATE_ENV" -Dnats.server.url="$NATS_SERVER_URL"
status=$?

"$SCRIPT_DIR/nats-stop.sh"

exit "$status"
