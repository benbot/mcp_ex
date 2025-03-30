defmodule McpEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :mcp_ex,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {McpEx.Application, []},
      extra_applications: [:logger, :runtime_tools, :observer, :wx]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:spark, "~> 2.2.46"},
      {:bandit, "~> 1.6.7"},
      {:ecto, "~> 3.10"},
      {:poison, "~> 6.0.0"},
      {:elixir_uuid, "~> 1.2"},
      {:polymorphic_embed, "~> 5.0"},
      {:sourceror, "~> 1.7", only: [:dev, :test]},
      {:shorthand, "~> 1.2.0"},
    ]
  end
end
