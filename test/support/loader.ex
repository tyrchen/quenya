defmodule Quenya.Loader do
  @moduledoc """
  Load the fixture file
  """
  alias Quenya.{Parser, Builder.Request}

  def load(name) do
    {:ok, result} =
      File.cwd!()
      |> Path.join("priv/fixture/#{name}/main.yml")
      |> Parser.parse()

    result
  end

  def gen, do: gen(load("todo"))

  def gen(data) do
    path = File.cwd!() |> Path.join("priv/gen")

    Enum.each(data["paths"], fn {uri, ops} ->
      Enum.each(ops, fn {method, _doc} ->
        Request.gen(data, uri, method, :quenya_todo, path: Path.join(path, "request"))
      end)
    end)
  end
end
