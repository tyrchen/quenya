defmodule QuenyaParser.Object.SecurityScheme do
  @moduledoc """
  SecurityScheme object
  """
  use TypedStruct
  alias QuenyaParser.Object.{SecurityScheme, Util}

  # security scheme options. We only support `apiKey` and `http` for security scheme at the moment
  @allowed_security_schema_type ["apiKey", "http"]
  # Auth scheme options. We only support `bearer` for auth scheme when scheme type is http
  @allowed_auth_scheme_type ["bearer"]
  # bearer options. We only support `JWT` at the moment.
  @allowed_bearer_type ["JWT"]

  typedstruct do
    @typedoc "Security scheme from the spec, we only support apiKey at the moment"
    field(:type, String.t(), enforce: true)
    field(:description, String.t(), default: "")
    field(:name, String.t(), default: "")
    field(:position, String.t(), default: "")
    field(:scheme, String.t(), default: "")
    field(:bearer_format, String.t(), default: "")
  end


  def new(data) do
    Enum.reduce(data || %{}, %{}, fn {name, item}, acc ->
      obj = gen_security_scheme_by_type(ensure_security_scheme_type(item["type"]), item)
      Map.put(acc, name, obj)
    end)
  end


  defp gen_security_scheme_by_type("apiKey", item) do
    %SecurityScheme{
      type: "apiKey",
      description: item["description"] || "",
      name:
        item["name"] || raise("name shall be defined for security scheme type #{item["type"]}"),
      position: Util.ensure_position(item["in"])
    }
  end

  defp gen_security_scheme_by_type("http", item) do
    %SecurityScheme{
      type: "http",
      description: item["description"] || "",
      scheme: ensure_auth_scheme_type(item["scheme"] || "bearer"),
      bearer_format: ensure_bearer_type(item["bearerFormat"] || "JWT")
    }
  end


  def ensure_security_scheme_type(v),
    do: Util.ensure_enum(v, @allowed_security_schema_type, "security scheme type")

  def ensure_auth_scheme_type(v),
    do: Util.ensure_enum(v, @allowed_auth_scheme_type, "auth scheme type")

  def ensure_bearer_type(v), do: Util.ensure_enum(v, @allowed_bearer_type, "bearer type")

end
