defmodule QuenyaTodo.Gen.UpdateTodo.ResponseValidator do
  @moduledoc false
  require Logger
  alias ExJsonSchema.Validator
  alias QuenyaUtil.RequestHelper
  alias Plug.Conn

  def init(opts) do
    opts
  end

  def validate(conn) do
    schemas = %{"200" => %{}, "default" => %{}}
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
      "200" => %{
        "application/json" => %{
          __struct__: ExJsonSchema.Schema.Root,
          custom_format_validator: nil,
          location: :root,
          refs: %{},
          schema: %{
            "example" => %{
              "body" => "hello world!",
              "created" => "2020-11-11T17:32:28Z",
              "id" => "16ba8d00-d44c-4f61-841f-2da8221091bc",
              "status" => "active",
              "updated" => "2020-11-11T19:32:28Z"
            },
            "properties" => %{
              "body" => %{"maxLength" => 140, "minLength" => 3, "type" => "string"},
              "created" => %{"format" => "date-time", "type" => "string"},
              "id" => %{"format" => "uuid", "type" => "string"},
              "status" => %{"enum" => ["active", "completed"], "type" => "string"},
              "updated" => %{"format" => "date-time", "type" => "string"}
            },
            "required" => ["body"],
            "type" => "object"
          }
        }
      },
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
