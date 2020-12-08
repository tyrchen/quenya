defmodule QuenyaParser.Object.Util do
  @moduledoc """
  Utility functions
  """
  alias QuenyaParser.Object.MediaType
  alias ExJsonSchema.Schema

  # postion for params. Regular restful API shouldn't read/write cookies so we remove its support
  @allowed_param_position ["query", "path", "header"]

  # We only support `simple` for path
  @allowed_path_param_style ["simple"]
  # We only support `simple` for header
  @allowed_header_param_style ["simple"]
  # We only support `form` for query
  @allowed_query_param_style ["form"]

  def gen_content(id, position, data) do
    Enum.reduce(data || %{}, %{}, fn {k, v}, acc ->
      Map.put(acc, k, MediaType.new(id, position, k, v))
    end)
  end

  def get_examples(data) do
    case data["example"] do
      nil -> data["examples"] || []
      v -> [v]
    end
  end

  def get_schema(id, position, name, data) do
    schema =
      data["schema"] ||
        raise "#{id}: shall define schema in the #{inspect(position)} for #{inspect(name)}. data: #{
                inspect(data)
              }"

    # schema example is deprecated and is unnecessary for json schema validation
    Schema.resolve(Map.delete(schema, "example"))
  end

  def ensure_position(v), do: ensure_enum(v, @allowed_param_position, "position")

  def ensure_param_style(nil, position) when position in ["header", "path"], do: "simple"
  def ensure_param_style(nil, position) when position in ["query", "cookie"], do: "form"

  def ensure_param_style(v, "header"),
    do: ensure_enum(v, @allowed_header_param_style, "header param style")

  def ensure_param_style(v, "path"),
    do: ensure_enum(v, @allowed_path_param_style, "path param style")

  def ensure_param_style(v, "query"),
    do: ensure_enum(v, @allowed_query_param_style, "query param style")

  def ensure_enum(v, choices, msg) do
    case v in choices do
      true -> v
      _ -> raise "Unsupported #{msg} #{v}, expected: #{inspect(choices)}."
    end
  end

end
