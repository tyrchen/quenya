defmodule Quenya.Umbrella do
  @moduledoc false
  use Quenya.Generator
  alias Quenya.Project

  template(:new, [
    {:eex, "quenya_umbrella/gitignore", :project, ".gitignore"},
    {:eex, "quenya_umbrella/config/config.exs", :project, "config/config.exs"},
    {:config, "quenya_umbrella/config/extra_config.exs", :project, "config/config.exs"},
    {:eex, "quenya_umbrella/config/dev.exs", :project, "config/dev.exs"},
    {:eex, "quenya_umbrella/config/test.exs", :project, "config/test.exs"},
    {:eex, "quenya_umbrella/config/prod.exs", :project, "config/prod.exs"},
    {:eex, "quenya_umbrella/mix.exs", :project, "mix.exs"},
    {:eex, "quenya_umbrella/README.md", :project, "README.md"},
    {:eex, "quenya_umbrella/formatter.exs", :project, ".formatter.exs"}
  ])

  def prepare_project(%Project{app: app} = project) when not is_nil(app) do
    project
    |> put_app()
    |> put_root_app()
  end

  defp put_app(project) do
    project_path = Path.expand(project.base_path <> "_umbrella")
    app_path = Path.join(project_path, "apps/#{project.app}")

    %Project{project | in_umbrella?: true, app_path: app_path, project_path: project_path}
  end

  defp put_root_app(%Project{app: app} = project) do
    %Project{
      project
      | root_app: :"#{app}_umbrella",
        root_mod: Module.concat(project.app_mod, "Umbrella")
    }
  end

  def generate(%Project{} = project) do
    if in_umbrella?(project.project_path) do
      Mix.raise("Unable to nest umbrella project within apps")
    end

    copy_from(project, __MODULE__, :new)
  end
end
