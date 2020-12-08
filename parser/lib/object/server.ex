defmodule QuenyaParser.Object.Server do
  @moduledoc """
  Server object. We do not process server variables for now.
  """
  use TypedStruct
  alias QuenyaParser.Object.{Server, ServerVariable}

  typedstruct do
    @typedoc "Server object from the spec"
    field(:url, String.t(), enforce: true)
    field(:description, String.t(), default: "")
    field(:variables, %{required(String.t()) => ServerVariable.t()}, default: %{})
    field(:x_env, String.t(), default: "dev")
  end

  def new(data) do
    %Server {
      url: data["url"],
      description: data["description"],
      variables: Enum.reduce(data["variables"] || %{}, %{}, fn {k, v}, acc -> Map.put(acc, k, ServerVariable.new(v)) end),
      x_env: data["x-env"]
    }
  end
end

defmodule QuenyaParser.Object.ServerVariable do
  @moduledoc """
  Server object
  """
  use TypedStruct
  alias QuenyaParser.Object.ServerVariable

  typedstruct  do
    @typedoc "Server variable object from the spec"
    field(:enum, [String.t()])
    field(:default, String.t(), enforce: true)
    field(:description, String.t(), default: "")
  end

  def new(data) do
    %ServerVariable {
      enum: data["enum"],
      default: data["default"],
      description: data["description"]
    }
  end
end
