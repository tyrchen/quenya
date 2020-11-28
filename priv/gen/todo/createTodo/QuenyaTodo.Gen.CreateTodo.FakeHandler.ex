defmodule QuenyaTodo.Gen.CreateTodo.FakeHandler do
  @moduledoc false
  require Logger
  alias QuenyaUtil.RequestHelper
  alias Plug.Conn

  def init(opts) do
    opts
  end

  def validate(conn) do
    schemas_with_code = %{
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
    }

    code = 201
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
