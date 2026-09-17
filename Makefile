export MOCK_BASE_URL := http://localhost:8080
export MOCK_URL      := $(MOCK_BASE_URL)/users

export GATLING_USERS        ?= 20
export GATLING_RAMP_SECONDS ?= 10

.DEFAULT_GOAL := help

.PHONY: help test test-dev test-ci mock-start mock-stop load-test demo clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

test: test-dev ## Alias for test-dev

test-dev: ## Run the functional Karate tests against the Dockerized mock (karate.env=dev)
	@scripts/functional-test.sh dev

test-ci: ## Run the functional Karate tests against the Dockerized mock (karate.env=ci, longer timeouts)
	@scripts/functional-test.sh ci

mock-start: ## Build (if needed) and start the mock API via Docker Compose, wait until healthy
	@scripts/mock-start.sh

mock-stop: ## Stop the mock API container started via mock-start
	@scripts/mock-stop.sh

load-test: ## Start the mock, run the Gatling load test, stop the mock (vars: GATLING_USERS, GATLING_RAMP_SECONDS)
	@scripts/load-test.sh

demo: test-ci load-test ## Run the full demo: functional tests, then the load test

clean: ## Remove build output and stop/remove any lingering mock API container
	mvn clean
	@docker compose down --remove-orphans 2>/dev/null || true
