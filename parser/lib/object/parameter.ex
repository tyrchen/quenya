defmodule QuenyaParser.Object.Parameter do
  @moduledoc """
  Parameter object
  """
  use TypedStruct
  alias QuenyaParser.Object.{Parameter, Util}

  typedstruct do
    @typedoc "Parameter object from the spec"
    field(:description, String.t(), default: "")
    field(:position, String.t(), enforce: true)
    field(:name, String.t(), enforce: true)
    field(:required, boolean(), enforce: true, default: false)
    field(:schema, ExJsonSchema.Schema.Root)
    field(:deprecated, boolean(), default: false)
    field(:style, String.t(), default: "simple")
    field(:explode, boolean(), default: false)
    field(:examples, list(map()))
  end

  def new(id, data) do
      name =
        data["name"] || raise "Shall define name in the request parameters. data: #{inspect(data)}"

      position = Util.ensure_position(data["in"])

      %Parameter{
        description: data["description"] || "",
        name: name,
        position: position,
        required: data["required"] || false,
        schema: Util.get_schema(id, "request parameters", name, data),
        deprecated: data["deprecated"] || false,
        style: Util.ensure_param_style(data["style"], position),
        explode: data["explode"] || false,
        examples: Util.get_examples(data)
      }
  end
end
