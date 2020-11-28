defmodule Petstore.MixProject do
  use Mix.Project

  def project do
    [
      app: :petstore,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: ["lib"],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Petstore.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:quenya, path: "../..", runtime: false},
      {:plug_cowboy, "~> 2.0"},
      {:json_data_faker, path: "../../../json_data_faker"}
    ]
  end
end
