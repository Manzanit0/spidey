defmodule Spidey.MixProject do
  use Mix.Project

  def project do
    [
      app: :spidey,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      escript: [main_module: CLI]
    ]
  end

  def application do
    [
      mod: {Spidey.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.7.0"},
      {:floki, "~> 0.21.0"},
      {:excoveralls, "~> 0.10", only: :test},
      {:mox, "~> 0.5", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end
