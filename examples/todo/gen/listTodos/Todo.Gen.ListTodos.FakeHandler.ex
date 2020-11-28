defmodule Todo.Gen.ListTodos.FakeHandler do
  @moduledoc false
  require Logger
  alias QuenyaUtil.{RequestHelper, ResponseHelper}
  alias Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
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

    {code, schemas_with_code} = Util.choose_best_code_schema(schemas)

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

    schema =
      Enum.reduce_while(accepts, nil, fn type, _acc ->
        case(Map.get(schemas_with_code, type)) do
          nil ->
            {:cont, nil}

          v ->
            {:halt, Keyword.put(v, :content_type, type)}
        end
      end) || schemas_with_code["application/json"] ||
        raise(Plug.BadRequestError, "accept content type #{inspect(accepts)} is not supported")

    content_type = Keyword.get(schema, :content_type, "application/json")
    resp = JsonDataFaker.generate(schema[:schema]) || ""

    conn
    |> Plug.Conn.put_resp_content_type(content_type)
    |> Plug.Conn.send_resp(code, ResponseHelper.encode(content_type, resp))
  end
end
