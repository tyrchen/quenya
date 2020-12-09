defmodule Parser.MixProject do
  use Mix.Project

  @version "0.3.7"
  def project do
    [
      app: :quenya_parser,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "Quenya Parser",
      docs: [
        extras: ["README.md"]
      ],
      source_url: "https://github.com/tyrchen/quenya",
      homepage_url: "https://github.com/tyrchen/quenya",
      description: """
      Parse OpenAPI v3 spec.
      """,
      package: package()
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
      {:deep_merge, "~> 1.0"},
      {:ex_json_schema, "~> 0.7"},
      {:jason, "~> 1.2"},
      {:typed_struct, "~> 0.2.1"},
      {:yaml_elixir, "~> 2.5"},

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
        "Docs" => "https://hexdocs.pm/quenya_parser"
      }
    ]
  end
end
