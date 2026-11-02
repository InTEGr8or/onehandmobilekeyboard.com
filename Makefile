#!/usr/bin/env bash
.PHONY: help start stop watch

LOG_DIR := .logs
PID_FILE := $(LOG_DIR)/eleventy.pid
URL_FILE := $(LOG_DIR)/url
PORT ?= 8082
REPO := $(abspath .)
ELEVENTY := ./node_modules/.bin/eleventy

help: ## Display this help screen
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z0-9_-]+:.*?## / {printf "  \033[32m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ==============================================================================
# Application Tasks
# ==============================================================================

# Stop the pid-file process and any other `eleventy --serve` whose cwd is this repo.
define stop_eleventy
	if [ -f $(PID_FILE) ]; then \
		pid=$$(cat $(PID_FILE)); \
		if [ -n "$$pid" ]; then \
			pkill -P $$pid 2>/dev/null || true; \
			kill $$pid 2>/dev/null || true; \
		fi; \
		rm -f $(PID_FILE); \
	fi; \
	for pid in $$(ps -eo pid=,args= | awk '/eleventy --serve/ && !/awk/ {print $$1}'); do \
		cwd=$$(readlink -f /proc/$$pid/cwd 2>/dev/null || true); \
		if [ "$$cwd" = "$(REPO)" ]; then \
			echo "Stopping leftover eleventy pid $$pid"; \
			kill $$pid 2>/dev/null || true; \
		fi; \
	done; \
	sleep 0.25
endef

start: ## Start the web server detached and print the URL and port
	@if [ ! -x $(ELEVENTY) ]; then npm ci; fi
	@mkdir -p $(LOG_DIR)
	@if [ -f $(PID_FILE) ] && kill -0 $$(cat $(PID_FILE)) 2>/dev/null; then \
		echo "Already running (pid $$(cat $(PID_FILE)))"; \
		echo "PORT=$(PORT)"; \
		echo "URL=http://localhost:$(PORT)/"; \
		echo "http://localhost:$(PORT)/" > $(URL_FILE); \
		exit 0; \
	fi; \
	$(stop_eleventy); \
	log="$(LOG_DIR)/$$(date +%Y-%m-%d).log"; \
	printf '\n=== start %s port=%s ===\n' "$$(date -Iseconds)" "$(PORT)" >> "$$log"; \
	nohup $(ELEVENTY) --serve --port=$(PORT) >> "$$log" 2>&1 & echo $$! > $(PID_FILE); \
	echo "Started eleventy (pid $$(cat $(PID_FILE)))"; \
	echo "Logging to $$log"; \
	url=""; \
	i=0; \
	while [ $$i -lt 40 ]; do \
		url=$$(grep -oE 'https?://localhost:$(PORT)[^[:space:]]*' "$$log" 2>/dev/null | tail -n 1); \
		if [ -n "$$url" ]; then break; fi; \
		if ! kill -0 $$(cat $(PID_FILE)) 2>/dev/null; then \
			echo "Eleventy exited. Last log lines:"; \
			tail -n 30 "$$log"; \
			rm -f $(PID_FILE); \
			exit 1; \
		fi; \
		i=$$((i + 1)); \
		sleep 0.25; \
	done; \
	if [ -z "$$url" ]; then \
		echo "Timed out waiting for the server. Last log lines:"; \
		tail -n 30 "$$log"; \
		exit 1; \
	fi; \
	echo "PORT=$(PORT)"; \
	echo "URL=$$url"; \
	echo "$$url" > $(URL_FILE)

stop: ## Stop the running web server
	@$(stop_eleventy)
	@rm -f $(URL_FILE)
	@echo "Stopped Eleventy for $(REPO)."

watch: ## Start the web server and tail-follow the log
	@$(MAKE) --no-print-directory start
	@log=$$(ls -1t $(LOG_DIR)/*.log 2>/dev/null | head -n 1); \
	echo "==> $$log"; \
	tail -n 40 -f "$$log"
