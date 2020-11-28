defmodule QuenyaTodo.Gen.ListTodos.FakeHandler do
  @moduledoc false
  require Logger
  alias QuenyaUtil.RequestHelper
  alias Plug.Conn

  def init(opts) do
    opts
  end

  def validate(conn) do
    schemas = %{
      "200" => %{
        "X-Cursor" => [
          schema: %{
            __struct__: ExJsonSchema.Schema.Root,
            custom_format_validator: nil,
            location: :root,
            refs: %{},
            schema: %{"type" => "string"}
          },
          required: true
        ]
      }
    }

    schemas_with_code = schemas[Integer.to_string(conn.status)] || schemas["default"]

    conn =
      Enum.reduce(schemas_with_code, conn, fn {name, schema}, acc ->
        v = JsonDataFaker.generate(schema[:schema])
        Conn.put_resp_header(acc, name, v)
      end)

    schemas_with_code = %{
      "application/json" => [
        schema: %{
          __struct__: ExJsonSchema.Schema.Root,
          custom_format_validator: nil,
          location: :root,
          refs: %{},
          schema: %{
            "items" => %{
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
            },
            "type" => "array"
          }
        },
        required: false
      ]
    }

    code = 200
    accepts = RequestHelper.get_accept(conn)

    {content_type, schema} =
      Enum.reduce_while(accepts, nil, fn type, acc ->
        case(Map.get(schemas_with_code, type)) do
          nil ->
            {:cont, {type, nil}}

          v ->
            {:halt, {type, v}}
        end
      end) || {"application/json", schemas_with_code["application/json"]} ||
        raise(Plug.BadRequestError, "accept content type #{inspect(accepts)} is not supported")

    Plug.Conn.put_resp_content_type(conn, content_type)
    resp = JsonDataFaker.generate(schema[:schema]) || ""
    Plug.Conn.send_resp(conn, code, resp)
  end
end
