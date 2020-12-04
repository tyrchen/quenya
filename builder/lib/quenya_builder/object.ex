defmodule QuenyaBuilder.Object do
  @moduledoc """
  Objects defined in OAPI specification
  """

  use TypedStruct

  alias QuenyaBuilder.Object.{Parameter, Request, Response, Header, MediaType}
  alias ExJsonSchema.Schema

  @allowed_param_position ["query", "path", "header", "cookie"]

  typedstruct module: Parameter do
    @typedoc "Parameter object from the spec"
    field :description, String.t(), default: ""
    field :position, atom(), default: :query
    field :name, String.t(), default: ""
    field :required, boolean(), default: false
    field :schema, ExJsonSchema.Schema.Root
    field :deprecated, boolean(), default: false
    field :style, atom(), default: :simple
    field :explode, boolean(), default: false
    field :examples, list(map())
  end

  typedstruct module: Request do
    @typedoc "Request object from the spec"
    field :description, String.t(), default: ""
    field :required, boolean(), default: false
    # a map of string -> MediaType
    field :content, map(), default: %{}
  end

  typedstruct module: MediaType do
    @typedoc "Media Type Object from the spec, we won't support `encoding` field at the moment"
    field :schema, ExJsonSchema.Schema.Root
    field :examples, list(map())
  end

  typedstruct module: Response do
    @typedoc "Response object from the spec, we won't support `links` filed at the moment"
    field :description, String.t(), default: ""
    field :headers, map(), default: %{}
    field :content, map(), default: %{}
  end

  typedstruct module: Header do
    @typedoc "Header object from the spec"
    field :description, String.t(), default: ""
    field :required, boolean(), default: false
    field :schema, ExJsonSchema.Schema.Root
    field :deprecated, boolean(), default: false
    field :style, atom(), default: :simple
    field :explode, boolean(), default: false
    field :examples, list(map())
  end

  def gen_req_object(_id, nil), do: %Request{}

  def gen_req_object(id, data) do
    content = gen_content(id, "request body", data["content"])

    %Request{
      description: data["description"],
      required: data["required"] || false,
      content: content
    }
  end

  def gen_param_objects(id, data) do
    Enum.map(data || [], fn p ->
      name =
        p["name"] || raise "Shall define name in the request parameters. data: #{inspect(data)}"

      %Parameter{
        description: p["description"] || "",
        name: name,
        position: ensure_position(p["in"]),
        required: p["required"] || false,
        schema: get_schema(id, "request parameters", name, p),
        deprecated: p["deprecated"] || false,
        style: p["style"] || :simple,
        explode: p["explode"] || false,
        examples: get_examples(p)
      }
    end)
  end

  def gen_res_objects(id, data) do
    Enum.reduce(data || %{}, %{}, fn {code, item}, res ->
      headers = gen_res_header_object(id, item["headers"])
      content = gen_content(id, "response body", item["content"])

      response = %Response{
        description: item["description"] || "",
        headers: headers,
        content: content
      }

      Map.put(res, code, response)
    end)
  end

  # private functions
  defp gen_content(id, position, data) do
    Enum.reduce(data || %{}, %{}, fn {k, v}, acc ->
      Map.put(acc, k, gen_media_type_object(id, position, k, v))
    end)
  end

  defp gen_media_type_object(id, position, type, data) do
    %MediaType{
      schema: get_schema(id, position, type, data),
      examples: get_examples(data)
    }
  end

  defp gen_res_header_object(id, data) do
    Enum.reduce(data || %{}, %{}, fn {k, v}, acc ->
      result = %Header{
        description: v["description"] || "",
        required: v["required"] || false,
        schema: get_schema(id, "response headers", k, v),
        deprecated: v["deprecated"] || false,
        style: v["style"] || :simple,
        explode: v["explode"] || false,
        examples: get_examples(v)
      }

      Map.put(acc, String.downcase(k), result)
    end)
  end

  defp ensure_position(position) do
    case position in @allowed_param_position do
      true -> position
      _ -> raise "Invalid position #{position}, expected: #{inspect(@allowed_param_position)}."
    end
  end

  defp get_examples(data) do
    case data["example"] do
      nil -> data["examples"] || []
      v -> [v]
    end
  end

  defp get_schema(id, position, name, data) do
    schema =
      data["schema"] ||
        raise "#{id}: shall define schema in the #{inspect(position)} for #{inspect(name)}. data: #{
                inspect(data)
              }"

    # schema example is deprecated and is unnecessary for json schema validation
    Schema.resolve(Map.delete(schema, "example"))
  end
end
