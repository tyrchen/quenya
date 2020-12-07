defmodule QuenyaBuilder.Object do
  @moduledoc """
  Objects defined in OAPI specification
  """

  use TypedStruct

  alias QuenyaBuilder.Object.{Parameter, Request, Response, Header, MediaType, SecurityScheme}
  alias ExJsonSchema.Schema

  # postion for params. Regular restful API shouldn't read/write cookies so we remove its support
  @allowed_param_position ["query", "path", "header"]
  # security scheme options. We only support `apiKey` and `http` for security scheme at the moment
  @allowed_security_schema_type ["apiKey", "http"]
  # Auth scheme options. We only support `bearer` for auth scheme when scheme type is http
  @allowed_auth_scheme_type ["bearer"]
  # bearer options. We only support `JWT` at the moment.
  @allowed_bearer_type ["JWT"]
  # We only support `simple` for path
  @allowed_path_param_style ["simple"]
  # We only support `simple` for header
  @allowed_header_param_style ["simple"]
  # We only support `form` for query
  @allowed_query_param_style ["form"]

  typedstruct module: Parameter do
    @typedoc "Parameter object from the spec"
    field :description, String.t(), default: ""
    field :position, String.t(), default: "query"
    field :name, String.t(), default: ""
    field :required, boolean(), default: false
    field :schema, ExJsonSchema.Schema.Root
    field :deprecated, boolean(), default: false
    field :style, String.t(), default: "simple"
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
    field :style, String.t(), default: "simple"
    field :explode, boolean(), default: false
    field :examples, list(map())
  end

  typedstruct module: SecurityScheme do
    @typedoc "Security scheme from the spec, we only support apiKey at the moment"
    field :type, String.t(), default: "apiKey"
    field :description, String.t(), default: ""
    field :name, String.t(), default: ""
    field :position, String.t(), default: ""
    field :scheme, String.t(), default: ""
    field :bearerFormat, String.t(), default: ""
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

      position = ensure_position(p["in"])

      %Parameter{
        description: p["description"] || "",
        name: name,
        position: position,
        required: p["required"] || false,
        schema: get_schema(id, "request parameters", name, p),
        deprecated: p["deprecated"] || false,
        style: ensure_param_style(p["style"], position),
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

  def gen_security_schemes(data) do
    Enum.reduce(data || %{}, %{}, fn {name, item}, acc ->
      obj = gen_security_scheme_by_type(ensure_security_scheme_type(item["type"]), item)
      Map.put(acc, name, obj)
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
        style: ensure_param_style(v["style"], "header"),
        explode: v["explode"] || false,
        examples: get_examples(v)
      }

      Map.put(acc, String.downcase(k), result)
    end)
  end

  defp ensure_position(v), do: ensure_enum(v, @allowed_param_position, "position")

  defp ensure_security_scheme_type(v),
    do: ensure_enum(v, @allowed_security_schema_type, "security scheme type")

  defp ensure_auth_scheme_type(v),
    do: ensure_enum(v, @allowed_auth_scheme_type, "auth scheme type")

  defp ensure_bearer_type(v), do: ensure_enum(v, @allowed_bearer_type, "bearer type")

  defp ensure_param_style(nil, position) when position in ["header", "path"], do: "simple"
  defp ensure_param_style(nil, position) when position in ["query", "cookie"], do: "form"

  defp ensure_param_style(v, "header"),
    do: ensure_enum(v, @allowed_header_param_style, "header param style")

  defp ensure_param_style(v, "path"),
    do: ensure_enum(v, @allowed_path_param_style, "path param style")

  defp ensure_param_style(v, "query"),
    do: ensure_enum(v, @allowed_query_param_style, "query param style")

  defp ensure_enum(v, choices, msg) do
    case v in choices do
      true -> v
      _ -> raise "Unsupported #{msg} #{v}, expected: #{inspect(choices)}."
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

  defp gen_security_scheme_by_type("apiKey", item) do
    %SecurityScheme{
      type: "apiKey",
      description: item["description"] || "",
      name:
        item["name"] || raise("name shall be defined for security scheme type #{item["type"]}"),
      position: ensure_position(item["in"])
    }
  end

  defp gen_security_scheme_by_type("http", item) do
    %SecurityScheme{
      type: "http",
      description: item["description"] || "",
      scheme: ensure_auth_scheme_type(item["scheme"] || "bearer"),
      bearerFormat: ensure_bearer_type(item["bearerFormat"] || "JWT")
    }
  end
end
