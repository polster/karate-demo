#!/usr/bin/env bash
# Runs the functional Karate tests against the mock API running via Docker Compose: starts
# the mock, runs the tests, and always stops the mock afterwards, even if the tests fail.
# Used by `make test-dev` / `make test-ci`.
#
# Usage: scripts/functional-test.sh <karate.env>
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KARATE_ENV="${1:-dev}"
MOCK_BASE_URL="${MOCK_BASE_URL:-http://localhost:8080}"

"$SCRIPT_DIR/mock-start.sh" || exit 1

mvn --batch-mode test -Dkarate.env="$KARATE_ENV" -Dmock.server.url="$MOCK_BASE_URL"
status=$?

"$SCRIPT_DIR/mock-stop.sh"

exit "$status"
