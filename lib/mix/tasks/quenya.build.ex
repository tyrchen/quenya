defmodule Mix.Tasks.Quenya.Build do
  @moduledoc """
  Rebuild code for a given Quenya project.

  It will overwrite code generated in `/gen` based on spec in `/priv/spec/main.yml`.

  ## Examples

      mix quenya.build

  """
  use Mix.Task
  alias Quenya.{Project, Generator}

  @shortdoc "Generate spec for an existing quenya app"

  def run(_argv) do
    spec_file = Path.join(File.cwd!(), "priv/spec/main.yml")

    case File.exists?(spec_file) do
      true ->
        config = Mix.Project.config()
        # TODO: support umbrella project later
        project = %Project{app: config[:app], app_path: "./"}
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
