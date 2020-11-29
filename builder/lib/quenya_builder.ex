defmodule QuenyaBuilder do
  @moduledoc """
  Build API routes based on OpenAPI v3 spec
  """

  alias Quenya.Parser
  alias QuenyaBuilder.Router

  @doc """
  Run quenya code generator
  """
  def run(filename, app) do
    path = Path.join(File.cwd!(), "gen")
    case Parser.parse(filename) do
      {:ok, spec} ->
        Router.gen(spec, app, path: path, create: false, output: false)
        :ok
      error -> error
    end
  end
end
