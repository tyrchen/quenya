defmodule QuenyaParser.Object.Operation do
  @moduledoc """
  Operation object, we won't support servers, callbacks. operationId is a MUST.
  """
  use TypedStruct
  alias QuenyaParser.Object.{ExternalDocument, Operation, Parameter, RequestBody, Response}

  typedstruct do
    @typedoc "Operation object from the spec"

    field(:tags, [String.t()], default: [])
    field(:summary, String.t(), default: "")
    field(:description, String.t(), default: "")
    field(:external_docs, ExternalDocument.t())
    field(:operation_id, String.t(), enforce: true)
    field(:parameters, [Parameter.t()], default: [])
    field(:request_body, %{required(String.t()) => RequestBody.t()}, default: %{})
    field(:responses, %{required(String.t()) => Response.t()}, default: %{})
    field(:deprecated, Boolean.t(), default: false)
    field(:security, %{required(String.t()) => [String.t()]}, default: %{})
  end

  def new(data) do
    id = data["operationId"] || raise "operationId is REQUIRED in quenya to generate the code"
    %Operation {
      tags: data["tags"] || "",
      summary: data["summary"] || "",
      description: data["description"] || "",
      external_docs: ExternalDocument.new(data["externalDocs"]),
      operation_id: id,
      parameters: Enum.map(data["parameters"] || [], fn p -> Parameter.new(id, p) end),
      request_body: RequestBody.new(id, data["requestBody"]),
      responses: Response.new(id, data["responses"]),
      deprecated: data["deprecated"] || false,
      security: data["security"]
    }
  end
end
