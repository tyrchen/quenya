defmodule Todo do
  @moduledoc """
  Generate todo code based on spec
  """

  {:ok, spec} =
    File.cwd!()
    |> Path.join("priv/spec/main.yml")
    |> QuenyaUtil.Parser.parse()

  path = File.cwd!() |> Path.join("gen")
  Quenya.Builder.Router.gen(spec, :todo, path: path)
end
