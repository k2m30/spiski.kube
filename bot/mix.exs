defmodule App.Mixfile do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "1.0.2",
      elixir: ">= 1.7.2",
      default_task: "server",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :logger_file_backend, :nadia, :poison, :redix, :jason, :logger_file_backend],
      mod: {App, []}
    ]
  end

  def deps do
    [
      {:nadia, "~> 0.7.0"},
      {:poison, "~> 3.1.0"},
      {:redix, "~> 1.0.0"},
      {:castore, "~> 0.1.8"},
      {:httpoison, "~> 1.7.0"},
      {:logger_file_backend, "~> 0.0.11"},
      {:distillery, "~> 2.0"}
    ]
  end

  defp aliases do
    [server: "run --no-halt"]
  end
end
