defmodule Mermaid.MixProject do
  use Mix.Project

  def project do
    [
      app: :mermaid,
      version: "1.0.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:assertions, "~> 0.20.1", only: :test},
      {:dg, "~> 0.4"},
      {:nimble_parsec, "~> 1.4"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end
end
