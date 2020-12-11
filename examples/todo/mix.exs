defmodule Todo.MixProject do
  use Mix.Project

  def project do
    [
      app: :todo,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Todo.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(env) when env in [:dev, :test], do: ["lib", "gen", "test/support"]
  defp elixirc_paths(_), do: ["lib", "gen"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},

      # Quenya
      {:quenya, path: "../..", override: true},

      # Quenya builder
      {:quenya_builder, path: "../../builder", override: true, runtime: false},

      # Only needed if you'd like to generate fake handler
      {:json_data_faker, "~> 0.1"},

      # dev and test
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
