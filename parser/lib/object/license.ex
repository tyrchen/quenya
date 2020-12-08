defmodule QuenyaParser.Object.License do
  @moduledoc """
  License object
  """
  use TypedStruct
  alias QuenyaParser.Object.License

  typedstruct do
    @typedoc "License object from the spec"
    field(:name, String.t(), enforce: true)
    field(:identifier, String.t(), default: "")
    field(:url, String.t(), default: "")
  end

  def new(nil), do: nil
  def new(data) when is_map(data) do
    %License {
      name: data["name"],
      identifier: data["identifier"],
      url: data["url"]
    }
  end

  def new(data), do: raise "Not a valid license object. Data: #{inspect(data)}"
end
