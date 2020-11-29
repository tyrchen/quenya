defmodule Quenya.MixProject do
  use Mix.Project

  @version "0.2.0"
  def project do
    [
      app: :quenya,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      compilers: Mix.compilers(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_json_schema, "~> 0.7"},
      {:yaml_elixir, "~> 2.5"},
      {:plug, "~>1.11"},
      {:jason, "~> 1.2"},
      {:uuid, "~> 1.0"},
      {:deep_merge, "~> 1.0"}
    ]
  end
end
