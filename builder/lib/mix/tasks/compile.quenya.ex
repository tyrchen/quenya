defmodule Mix.Tasks.Compile.Quenya do
  @moduledoc """
  Generate source code based on OpenAPI v3 sepc for todo.
  This will create a `/gen` folder and overwrite all files in it.
  The files are generated based on `operationId` in the spec
  Todo keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  use Mix.Task.Compiler

  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:quenya)
    build_spec()
  end

  defp build_spec do
    cwd = File.cwd!()
    filename = Path.join(cwd, "priv/spec/main.yml")
    app = Mix.Project.config()[:app]
    QuenyaBuilder.run(filename, app)
  end
end
