defmodule Todo.Gen.DeleteTodo.FakeHandler do
  @moduledoc false
  require Logger
  alias QuenyaUtil.{RequestHelper, ResponseHelper}
  alias Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    schemas_with_code = %{
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
