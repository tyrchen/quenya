defmodule QuenyaParser.Object.Header do
  @moduledoc """
  Header object
  """

  use TypedStruct
  alias QuenyaParser.Object.{Header, Util}

  typedstruct do
    @typedoc "Header object from the spec"
    field(:description, String.t(), default: "")
    field(:required, boolean(), default: false)
    field(:schema, ExJsonSchema.Schema.Root)
    field(:deprecated, boolean(), default: false)
    field(:style, String.t(), default: "simple")
    field(:explode, boolean(), default: false)
    field(:examples, list(map()))
  end

  def new(id, data) do
    Enum.reduce(data || %{}, %{}, fn {k, v}, acc ->
      result = %Header{
        description: v["description"] || "",
        required: v["required"] || false,
        schema: Util.get_schema(id, "response headers", k, v),
        deprecated: v["deprecated"] || false,
        style: Util.ensure_param_style(v["style"], "header"),
        explode: v["explode"] || false,
        examples: Util.get_examples(v)
      }

      Map.put(acc, String.downcase(k), result)
    end)
  end
end
