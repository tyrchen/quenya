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
    paths = Enum.reduce(data["paths"] || %{}, %{}, fn {uri, ops}, acc1 ->
      result = Enum.reduce(ops, %{}, fn {method, op}, acc2 ->
        Map.put(acc2, method, Operation.new(uri, method, op))
      end)
      Map.put(acc1, uri, result)
    end)

    if Enum.empty?(paths) do
      raise "No route definition in schema"
    end

    %OpenApi {
      openapi: data["openapi"],
      info: Info.new(data["info"]),
      servers: Enum.map(data["servers"] || [], &Server.new/1),
      paths: paths,
      security: data["security"] || [],
      security_schemes: SecurityScheme.new(data["components"]["securitySchemes"]),
      external_docs: ExternalDocument.new(data["externalDocs"])
    }
  end

end
