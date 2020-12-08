defmodule QuenyaParser.Object.OpenApi do
  @moduledoc """
  OpenApi Object
  """
  use TypedStruct
  alias QuenyaParser.Object.{
    ExternalDocument,
    Info,
    OpenApi,
    Operation,
    SecurityScheme,
    Server
  }

  typedstruct do
    @typedoc "OpenApi object from the spec"
    field(:openapi, String.t(), enforce: true)
    field(:info, Info.t(), enforce: true)
    field(:servers, [Server.t()])
    field(:paths, %{required(String.t()) => %{String.t() => Operation.t()}})
    field(:security, [%{required(String.t()) => [String.t()]}], default: [])
    field(:security_schemes, %{required(String.t()) => SecurtyScheme.t()}, default: %{})
    field(:external_docs, ExternalDocumentation.t())
  end


  def new(data) do
    paths = Enum.reduce(data["paths"], %{}, fn {k1, v1}, acc1 ->
      result = Enum.reduce(v1, %{}, fn {k2, v2}, acc2 ->
        Map.put(acc2, k2, Operation.new(v2))
      end)
      Map.put(acc1, k1, result)
    end)

    %OpenApi {
      openapi: data["openapi"],
      info: Info.new(data["info"]),
      servers: Enum.map(data["servers"] || [], &Server.new/1),
      paths: paths,
      security: data["security"] || %{},
      security_schemes: Enum.reduce(data["components"]["security_scheme"] || %{}, %{}, fn {k, v}, acc -> Map.put(acc, k, SecurityScheme.new(v)) end),
      external_docs: ExternalDocument.new(data["externalDocs"])
    }
  end

end
