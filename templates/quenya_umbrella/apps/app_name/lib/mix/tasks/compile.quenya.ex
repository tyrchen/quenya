defmodule Mix.Tasks.Compile.Quenya do
  @moduledoc """
  Generate source code based on OpenAPI v3 sepc for <%= @app_name %>.
  This will create a `/gen` folder and overwrite all files in it.
  The files are generated based on `operationId` in the spec
  <%= @app_module %> keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  use Mix.Task

  def run(_args) do
    build_spec()
  end

  defp build_spec do
    cwd = File.cwd!()
    filename = Path.join(cwd, "priv/spec/main.yml")
    case QuenyaUtil.Parser.parse(filename) do
      {:ok, spec} ->
        Quenya.Builder.Router.gen(spec, :<%= @app_name %>, path: Path.join(cwd, "gen"), create?: false, output?: false)
        :ok
      error -> error
    end




  end
end
