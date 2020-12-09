defmodule QuenyaBuilder.MixProject do
  use Mix.Project

  @version "0.3.7"
  def project do
    [
      app: :quenya_builder,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "QuenyaBuilder",
      docs: [
        extras: ["README.md"]
      ],
      source_url: "https://github.com/tyrchen/quenya",
      homepage_url: "https://github.com/tyrchen/quenya",
      description: """
      Build API routes based on OpenAPI v3 spec.
      """,
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dynamic_module_new, "~> 0.1"},
      {:ex_json_schema, "~> 0.7"},
      {:jason, "~> 1.2"},
      {:json_data_faker, "~> 0.2"},
      {:plug, "~> 1.11"},
      {:quenya, "~> 0.3"},
      {:quenya_parser, "~> 0.3"},
      {:recase, "~> 0.7"},
      {:stream_data, "~> 0.5"},

      # dev/test deps
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: [:dev]}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "../LICENSE*"],
      licenses: ["MIT"],
      maintainers: ["tyr.chen@gmail.com"],
      links: %{
        "GitHub" => "https://github.com/tyrchen/quenya",
        "Docs" => "https://hexdocs.pm/quenya_builder"
      }
    ]
  end
end
