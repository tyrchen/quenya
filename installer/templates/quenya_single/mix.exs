defmodule <%= @app_module %>.MixProject do
  use Mix.Project

  def project do
    [
      app: :<%= @app_name %>,
      version: "0.1.0",<%= if @in_umbrella do %>
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",<% end %>
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers() ++ [:quenya],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {<%= @app_module %>.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "gen", "test/support"]
  defp elixirc_paths(_), do: ["lib", "gen"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},

      # Quenya
      {:quenya, git: "git@github.com:tyrchen/quenya"},

      # Quenya builder
      {:quenya_builder, git: "git@github.com:tyrchen/quenya", sparse: "builder", runtime: false},

      # Only needed if you'd like to generate fake handler
      {:json_data_faker, git: "git@github.com:tyrchen/json_data_faker"}
    ]
  end
end
