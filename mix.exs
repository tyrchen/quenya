defmodule Quenya.MixProject do
  use Mix.Project

  @version "0.1.0"

  def version, do: @version

  def project do
    [
      app: :quenya,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      compilers: Mix.compilers(),
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      escript: escript()
    ]
  end

  def application do
    [extra_applications: [:logger, :mix]]
  end

  def escript do
    [main_module: Quenya]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dynamic_module, "~> 0.1"},
      {:jason, "~> 1.2"},
      {:deep_merge, "~> 1.0"},
      {:plug, "~> 1.11"},
      {:recase, "~> 0.7"},
      {:ex_json_schema, "~> 0.7"},
      {:quenya_util, path: "../quenya_util"},
      {:json_data_faker, path: "../json_data_faker"},
      {:optimus, "~> 0.2"}
      # {:quenya_util, git: "git@github.com:tyrchen/quenya_util"},
      # {:json_data_faker, git: "git@github.com:tyrchen/json_data_faker"}
    ]
  end
end
