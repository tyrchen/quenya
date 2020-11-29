defmodule QuenyaBuilder.MixProject do
  use Mix.Project

  @version "0.2.0"
  def project do
    [
      app: :quenya_builder,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dynamic_module, "~> 0.1"},
      {:jason, "~> 1.2"},
      {:plug, "~> 1.11"},
      {:recase, "~> 0.7"},
      {:ex_json_schema, "~> 0.7"},
      # {:quenya, path: ".."},
      # {:json_data_faker, path: "../../json_data_faker"}
      {:quenya, git: "git@github.com:tyrchen/quenya"},
      {:json_data_faker, git: "git@github.com:tyrchen/json_data_faker"}
    ]
  end
end
