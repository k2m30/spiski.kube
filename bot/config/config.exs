use Mix.Config

config :app,
  bot_name: "SpiskiLiveBot"

config :nadia,
  token: System.get_env("BOT_TOKEN")

import_config "#{Mix.env}.exs"

config :logger,
       backends: [:console, {LoggerFileBackend, :error_log}],
       format: "[$level] $message\n"

config :logger, :error_log,
       path: "/tmp/bot.log",
       level: :info
