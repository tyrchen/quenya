defmodule QuenyaBuilder do
  @moduledoc """
  Build API routes based on OpenAPI v3 spec
  """

  alias QuenyaBuilder.Generator.Router

  @doc """
  Run quenya code generator
  """
  def run(filename, app) do
    path = Path.join(File.cwd!(), "gen")

    case QuenyaParser.parse(filename) do
      {:ok, spec} ->
        Router.gen(spec, app, path: path, create: false, output: false)
        :ok

      error ->
        error
    end
  end
end
