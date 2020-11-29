defmodule Quenya.CLI.Build do
  @moduledoc """
  Rebuild code for a given Quenya project.

  It will overwrite code generated in `/gen` based on spec in `/priv/spec/main.yml`.
  """
  alias Quenya.{Project, Generator}

  def run(_args, _opts) do
    spec_file = Path.join(File.cwd!(), "priv/spec/main.yml")

    case File.exists?(spec_file) do
      true ->
        [{mod, _}] = Code.compile_file("mix.exs")
        config = apply(mod, :project, [])
        # TODO: support umbrella project later
        project = %Project{app: Atom.to_string(config[:app]), app_path: "./"}
        Generator.build_spec(project)

        Mix.shell().info([
          :green,
          "code regenerated based on spec in priv/spec/main.yml."
        ])

      _ ->
        Mix.shell().info([
          :red,
          "Failed to find spec in priv/spec/main.yml. Please make sure you're in a Quenya app."
        ])
    end
  end
end
