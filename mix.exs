defmodule Quenya.MixProject do
  use Mix.Project

  def project do
    [
      app: :quenya,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      compilers: Mix.compilers(),
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Quenya.Application, []},
      env: [
        use_fake_handler: true,
        use_response_validator: true,
        apis: %{}
      ]
    ]
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
      {:json_data_faker, path: "../json_data_faker"}
      # {:quenya_util, git: "git@github.com:tyrchen/quenya_util"},
      # {:json_data_faker, git: "git@github.com:tyrchen/json_data_faker"}
    ]
  end
end
