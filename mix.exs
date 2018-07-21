defmodule Reminder.MixProject do
  use Mix.Project

  def project do
    [
      app: :reminder,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Reminder, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      {:mailman, git: "https://github.com/mailman-elixir/mailman.git"},
      {:excoveralls, "~> 0.8", only: :test},
      {:pre_commit, git: "https://github.com/dwyl/elixir-pre-commit.git", only: :dev}
    ]
  end
end
