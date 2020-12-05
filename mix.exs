defmodule Quenya.MixProject do
  use Mix.Project

  @version "0.3.4"
  def project do
    [
      app: :quenya,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      compilers: Mix.compilers(),
      deps: deps(),

      # Docs
      name: "Quenya",
      docs: [
        extras: ["README.md"]
      ],
      source_url: "https://github.com/tyrchen/quenya",
      homepage_url: "https://github.com/tyrchen/quenya",
      description: """
      Fast. Reusable. Quenya framework helps you generate and build OpenAPIv3
      compatible API apps easily from a spec. It greatly reduced the time to
      build APIs from ideation to production.
      """,
      package: package()
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
      {:deep_merge, "~> 1.0"},
      {:ex_json_schema, "~> 0.7"},
      {:jason, "~> 1.2"},
      {:joken, "~> 2.0"},
      {:json_data_faker, "~> 0.2"},
      {:plug, "~>1.11"},
      {:stream_data, "~> 0.5"},
      {:uuid, "~> 1.0"},
      {:yaml_elixir, "~> 2.5"},

      # dev/test deps
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test]}
    ]
  end

  defp package do
    [
      files: ["lib", "priv", "mix.exs", "README*", "LICENSE*"],
      licenses: ["MIT"],
      maintainers: ["tyr.chen@gmail.com"],
      links: %{
        "GitHub" => "https://github.com/tyrchen/quenya",
        "Docs" => "https://hexdocs.pm/quenya"
      }
    ]
  end
end
