defmodule Petstore.CodeGen do

  {:ok, spec} =
    File.cwd!()
    |> Path.join("priv/spec/main.yml")
    |> Quenya.Parser.parse()

  path = File.cwd!() |> Path.join("gen")
  Quenya.Builder.Router.gen(spec, :petstore,path: path)
end
