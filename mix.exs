defmodule ExScapper.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_scapper,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExScapper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.4"},
      {:floki, "~> 0.20.0"},
      {:jason, "~> 1.0"},
      {:ex_crypto, "~> 0.10.0"},
      {:timex, "~> 3.0"}
    ]
  end
end
