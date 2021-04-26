build:
	docker build \
        --build-arg BOT_TOKEN=$(BOT_TOKEN) \
        --build-arg REDIS_HOST=$(REDIS_HOST) \
        --build-arg REDIS_PASSWORD=$(REDIS_PASSWORD) \
        -t k2m30/elixir_bot:latest .

run:
	docker run --rm -it k2m30/elixir_bot:latest