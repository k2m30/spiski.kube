FROM elixir:1.11 AS builder
ARG APP_VSN=latest
ARG MIX_ENV=prod
ARG BOT_TOKEN
ARG REDIS_HOST
ARG REDIS_PASSWORD

WORKDIR /opt/app

RUN \
  mix local.rebar --force && \
  mix local.hex --force

COPY mix* ./

RUN mix do deps.get, deps.compile

ENV APP_VSN=${APP_VSN} \
    MIX_ENV=${MIX_ENV} \
    BOT_TOKEN=${BOT_TOKEN} \
    REDIS_HOST=${REDIS_HOST} \
    REDIS_PASSWORD=${REDIS_PASSWORD}

RUN echo "Host: $REDIS_HOST" && \
    echo "Pass: $REDIS_PASSWORD" && \
    echo "Token: $BOT_TOKEN" && \
    echo "App: $APP_VSN"

COPY . .
RUN mix compile

CMD mix
#CMD ping tut.by