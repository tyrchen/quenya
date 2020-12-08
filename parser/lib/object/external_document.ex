defmodule QuenyaParser.Object.ExternalDocument do
  @moduledoc """
  External doc
  """
  use TypedStruct
  alias QuenyaParser.Object.ExternalDocument

  typedstruct do
    @typedoc "ExternalDocument object from the spec"
    field(:description, String.t(), default: "")
    field(:url, String.t(), enforce: true)
  end

  def new(nil), do: nil
  def new(data) when is_map(data) do
    %ExternalDocument {
      description: data["description"] || "",
      url: data["url"]
    }
  end

  def new(data), do: raise "Not a valid external document object. Data: #{inspect(data)}"
end
