defmodule QuenyaParser.Object.Contact do
  @moduledoc """
  License object
  """
  use TypedStruct
  alias QuenyaParser.Object.Contact

  typedstruct do
    @typedoc "Contact object from the spec"
    field(:name, String.t(), default: "")
    field(:url, String.t(), default: "")
    field(:email, String.t(), default: "")
  end


  def new(nil), do: nil
  def new(data) when is_map(data) do
    %Contact {
      name: data["name"],
      url: data["url"],
      email: data["email"],
    }
  end

  def new(data), do: raise "Not a valid contact object. Data: #{inspect(data)}"
end
