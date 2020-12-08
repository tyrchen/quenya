defmodule QuenyaParser.Object.Response do
  @moduledoc """
  Response object
  """
  use TypedStruct
  alias QuenyaParser.Object.{Header, MediaType, Response, Util}

  typedstruct do
    @typedoc "Response object from the spec, we won't support `links` filed at the moment"
    field(:description, String.t(), default: "")
    field(:headers, %{required(String.t()) => Header.t()}, default: %{})
    field(:content, %{required(String.t()) => MediaType.t()}, default: %{})
  end

  def new(id, data) do
    Enum.reduce(data || %{}, %{}, fn {code, item}, res ->
      headers = Header.new(id, item["headers"])
      content = Util.gen_content(id, "response body", item["content"])

      response = %Response{
        description: item["description"] || "",
        headers: headers,
        content: content
      }

      Map.put(res, code, response)
    end)
  end
end
