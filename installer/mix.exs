defmodule QuenyaInstaller.MixProject do
  use Mix.Project

  @version "0.1.0"
  def project do
    [
      app: :quenya_installer,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    []
  end
end
