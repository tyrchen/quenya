defmodule Quenya.Single do
  @moduledoc false
  use Quenya.Generator
  alias Quenya.Project

  template(:new, [
    # config files
    {:eex, "quenya_single/config/config.exs", :project, "config/config.exs"},
    {:eex, "quenya_single/config/dev.exs", :project, "config/dev.exs"},
    {:eex, "quenya_single/config/prod.exs", :project, "config/prod.exs"},
    {:eex, "quenya_single/config/staging.exs", :project, "config/staging.exs"},
    {:eex, "quenya_single/config/test.exs", :project, "config/test.exs"},

    # application files
    {:eex, "quenya_single/lib/mix/tasks/compile.quenya.ex", :project,
     "lib/mix/tasks/compile.quenya.ex"},

    # mix task files
    {:eex, "quenya_single/lib/app_name/application.ex", :project, "lib/:app/application.ex"},
    {:eex, "quenya_single/lib/app_name.ex", :project, "lib/:app.ex"},

    # project files
    {:eex, "quenya_single/mix.exs", :project, "mix.exs"},
    {:eex, "quenya_single/README.md", :project, "README.md"},
    {:eex, "quenya_single/formatter.exs", :project, ".formatter.exs"},
    {:eex, "quenya_single/gitignore", :project, ".gitignore"},

    # test files
    {:eex, "quenya_single/test/test_helper.exs", :project, "test/test_helper.exs"}
  ])

  template(:bare, [])

  def prepare_project(%Project{app: app} = project) when not is_nil(app) do
    %Project{project | project_path: project.base_path}
    |> put_app()
    |> put_root_app()
  end

  defp put_app(%Project{base_path: base_path} = project) do
    %Project{project | in_umbrella?: in_umbrella?(base_path), app_path: base_path}
  end

  defp put_root_app(%Project{app: app, opts: opts} = project) do
    %Project{
      project
      | root_app: app,
        root_mod: Module.concat([opts[:module] || Macro.camelize(app)])
    }
  end

  def generate(%Project{} = project) do
    copy_from(project, __MODULE__, :new)
    project
  end

  def gen_bare(%Project{} = project) do
    copy_from(project, __MODULE__, :bare)
  end
end
