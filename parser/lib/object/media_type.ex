
defmodule QuenyaParser.Object.MediaType do
  @moduledoc """
  License object
  """
  use TypedStruct
  alias QuenyaParser.Object.{MediaType, Util}

  typedstruct do
    @typedoc "Media Type Object from the spec, we won't support `encoding` field at the moment"
    field(:schema, ExJsonSchema.Schema.Root)
    field(:examples, list(map()))
  end

  def new(id, position, type, data) do
    %MediaType {
      schema: Util.get_schema(id, position, type, data),
      examples: Util.get_examples(data)
    }
  end

end
