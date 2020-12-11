defmodule QuenyaInstaller.MixProject do
  use Mix.Project

  @version "0.3.8"
  def project do
    [
      app: :quenya_installer,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "QuenyaInstaller",
      docs: [
        extras: ["README.md"]
      ],
      source_url: "https://github.com/tyrchen/quenya",
      homepage_url: "https://github.com/tyrchen/quenya",
      description: """
      Quenya mix CLI to create new quenya powered app.
      """,
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # dev/test deps
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: [:dev]}
    ]
  end

  defp package do
    [
      files: ["lib", "templates", "mix.exs", "README*", "../LICENSE*"],
      licenses: ["MIT"],
      maintainers: ["tyr.chen@gmail.com"],
      links: %{
        "GitHub" => "https://github.com/tyrchen/quenya",
        "Docs" => "https://hexdocs.pm/quenya_installer"
      }
    ]
  end
end
