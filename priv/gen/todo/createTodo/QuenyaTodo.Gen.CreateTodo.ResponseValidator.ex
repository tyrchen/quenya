defmodule QuenyaTodo.Gen.CreateTodo.ResponseValidator do
  @moduledoc false
  require Logger
  alias ExJsonSchema.Validator
  alias QuenyaUtil.RequestHelper
  alias Plug.Conn

  def init(opts) do
    opts
  end

  def validate(conn) do
    schemas = %{
      "201" => %{
        "application/json" => [
          schema: %{
            __struct__: ExJsonSchema.Schema.Root,
            custom_format_validator: nil,
            location: :root,
            refs: %{},
            schema: %{
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
          },
          required: false
        ]
      },
      "default" => %{
        "application/json" => [
          schema: %{
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
          },
          required: false
        ]
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

    case(Validator.validate(schema[:schema], data)) do
      {:error, [{msg, _} | _]} ->
        raise(Plug.BadRequestError, msg)

      :ok ->
        :ok
    end

    conn
  end
end
