.PHONY: help

APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`

help:
	@echo "elixir_bot:$(APP_VSN)-$(BUILD)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker build \
        --build-arg APP_VSN=$(APP_VSN) \
        --build-arg BOT_TOKEN=$(BOT_TOKEN) \
        --build-arg REDIS_HOST=$(REDIS_HOST) \
        --build-arg REDIS_PASSWORD=$(REDIS_PASSWORD) \
        -t k2m30/elixir_bot:latest .

run:
	docker run --rm -it k2m30/elixir_bot:latest