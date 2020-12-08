defmodule QuenyaParser.Object.RequestBody do
  @moduledoc """
  RequestBody object
  """
  use TypedStruct
  alias QuenyaParser.Object.{RequestBody, Util}

  typedstruct do
    @typedoc "RequestBody object from the spec"
    field(:description, String.t(), default: "")
    field(:required, boolean(), default: false)
    # a map of string -> MediaType
    field(:content, %{required(String.t()) => MediaType.t()}, default: %{})
  end

  def new(_id, nil), do: %RequestBody{}
  def new(id, data) do
    content = Util.gen_content(id, "request body", data["content"])

    %RequestBody{
      description: data["description"],
      required: data["required"] || false,
      content: content
    }
  end

end
