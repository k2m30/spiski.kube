ARG ALPINE_VERSION=3.13
FROM elixir:1.11-alpine AS builder
ARG APP_VSN=latest
ARG MIX_ENV=prod
ARG BOT_TOKEN
ARG REDIS_HOST
ARG REDIS_PASSWORD

WORKDIR /opt/app

RUN \
  apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
    build-base && \
  mix local.rebar --force && \
  mix local.hex --force

COPY mix* ./
RUN mix do deps.get, deps.compile

ENV APP_VSN=${APP_VSN} \
    MIX_ENV=${MIX_ENV} \
    BOT_TOKEN=${BOT_TOKEN} \
    REDIS_HOST=${REDIS_HOST} \
    REDIS_PASSWORD=${REDIS_PASSWORD}

RUN echo "Host: $REDIS_HOST"
RUN echo "Pass: $REDIS_PASSWORD"
RUN echo "Token: $BOT_TOKEN"
RUN echo "App: $APP_VSN"

COPY . .
RUN mix compile

RUN \
  mkdir -p /opt/built && \
  mix distillery.release --verbose && \
  cp _build/${MIX_ENV}/rel/app/releases/${APP_VSN}/app.tar.gz /opt/built && \
  cd /opt/built && \
  tar -xzf app.tar.gz && \
  rm app.tar.gz

FROM alpine:${ALPINE_VERSION}

RUN apk update && \
    apk add --no-cache \
      bash \
      openssl-dev

ENV REPLACE_OS_VARS=true

WORKDIR /opt/app

COPY --from=builder /opt/built .

CMD trap 'exit' INT; /opt/app/bin/app foreground