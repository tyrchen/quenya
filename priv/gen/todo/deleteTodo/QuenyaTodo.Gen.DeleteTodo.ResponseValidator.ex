defmodule QuenyaTodo.Gen.DeleteTodo.ResponseValidator do
  @moduledoc false
  require Logger
  alias ExJsonSchema.Validator
  alias QuenyaUtil.RequestHelper
  alias Plug.Conn

  def init(opts) do
    opts
  end

  def validate(conn) do
    schemas = %{"204" => %{}, "default" => %{}}
    schemas_with_code = schemas[Integer.to_string(conn.status)] || schemas["default"]

    Enum.map(schemas_with_code, fn {name, {schema, required}} ->
      v = RequestHelper.get_param(conn, name, "resp_header")

      if(required) do
        RequestHelper.validate_required(v, required, "resp_header")
      end

      case(Validator.validate(schema, v)) do
        {:error, [{msg, _} | _]} ->
          raise(Plug.BadRequestError, msg)

        :ok ->
          :ok
      end
    end)

    schemas = %{
      "204" => %{},
      "default" => %{
        "application/json" => %{
          __struct__: ExJsonSchema.Schema.Root,
          custom_format_validator: nil,
          location: :root,
          refs: %{},
          schema: %{
            "properties" => %{
              "code" => %{"format" => "int32", "type" => "integer"},
              "message" => %{"type" => "string"}
            },
            "required" => ["code", "message"],
            "type" => "object"
          }
        }
      }
    }

    accepts = RequestHelper.get_accept(conn)
    schemas_with_code = schemas[Integer.to_string(conn.status)] || schemas["default"]

    schema =
      Enum.reduce_while(accepts, nil, fn type, acc ->
        case(Map.get(schemas_with_code, type)) do
          nil ->
            {:cont, nil}

          v ->
            {:halt, v}
        end
      end) || schemas_with_code["application/json"] ||
        raise(Plug.BadRequestError, "accept content type #{inspect(accepts)} is not supported")

    data = conn.resp_body

    case(Validator.validate(schema, data)) do
      {:error, [{msg, _} | _]} ->
        raise(Plug.BadRequestError, msg)

      :ok ->
        :ok
    end

    conn
  end
end
