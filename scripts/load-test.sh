#!/usr/bin/env bash
# Runs the Gatling load test against the mock API: starts the mock, runs the simulation, and
# always stops the mock afterwards, even if the simulation fails. Used by `make load-test`.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GATLING_USERS="${GATLING_USERS:-20}"
GATLING_RAMP_SECONDS="${GATLING_RAMP_SECONDS:-10}"

"$SCRIPT_DIR/mock-start.sh" || exit 1

mvn --batch-mode test-compile gatling:test \
  -Dgatling.users="$GATLING_USERS" -Dgatling.rampSeconds="$GATLING_RAMP_SECONDS"
status=$?

"$SCRIPT_DIR/mock-stop.sh"

exit "$status"
