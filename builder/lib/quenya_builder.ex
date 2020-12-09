defmodule QuenyaBuilder do
  @moduledoc """
  Build API routes based on OpenAPI v3 spec
  """

  alias QuenyaBuilder.Generator.Router
  alias QuenyaParser.Object.OpenApi

  @doc """
  Run quenya code generator
  """
  def run(filename, app) do
    path = Path.join(File.cwd!(), "gen")

    case QuenyaParser.parse_as_map(filename) do
      {:ok, data} ->
        json_filename = "#{filename}.json"
        File.write!(json_filename, Jason.encode!(data))
        spec = OpenApi.new(data)
        Router.gen(spec, app, path: path, create: false, output: false)
        :ok

      error ->
        error
    end
  end
end
