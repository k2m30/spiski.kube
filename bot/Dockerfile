ARG ALPINE_VERSION=3.8
FROM elixir:1.7.2-alpine AS builder
ARG APP_VSN
ARG MIX_ENV=prod
ARG BOT_TOKEN

ENV APP_VSN=${APP_VSN} \
    MIX_ENV=${MIX_ENV} \
    BOT_TOKEN=${BOT_TOKEN}

WORKDIR /opt/app


RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
    nodejs \
    yarn \
    git \
    build-base && \
  mix local.rebar --force && \
  mix local.hex --force

# This copies our app source code into the build container
COPY mix* ./
RUN mix do deps.get, deps.compile

COPY . .
RUN mix compile

RUN \
  mkdir -p /opt/built && \
  mix distillery.release --verbose && \
  cp _build/${MIX_ENV}/rel/app/releases/${APP_VSN}/app.tar.gz /opt/built && \
  cd /opt/built && \
  tar -xzf app.tar.gz && \
  rm app.tar.gz

# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:${ALPINE_VERSION}

RUN apk update && \
    apk add --no-cache \
      bash \
      openssl-dev

ENV REPLACE_OS_VARS=true

WORKDIR /opt/app

COPY --from=builder /opt/built .

CMD trap 'exit' INT; /opt/app/bin/app foreground