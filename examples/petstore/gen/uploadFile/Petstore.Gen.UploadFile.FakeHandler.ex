defmodule Petstore.Gen.UploadFile.FakeHandler do
  @moduledoc false
  require Logger
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    {_, schemas} = get_header_schemas()

    conn =
      Enum.reduce(schemas, conn, fn {name, schema, _required}, acc ->
        v =
          case(Quenya.TestHelper.get_one(JsonDataFaker.generate(schema))) do
            v when is_binary(v) ->
              v

            v when is_integer(v) ->
              Integer.to_string(v)

            v ->
              "#{inspect(v)}"
          end

        Plug.Conn.put_resp_header(acc, name, v)
      end)

    {code, schemas} = get_body_schemas()
    accepts = Quenya.RequestHelper.get_accept(conn)

    {content_type, schema} =
      Enum.reduce_while(accepts, nil, fn type, _acc ->
        case(Map.get(schemas, type)) do
          nil ->
            {:cont, nil}

          v ->
            {:halt, v}
        end
      end) || schemas["application/json"] ||
        raise(Plug.BadRequestError, "accept content type #{inspect(accepts)} is not supported")

    resp = Quenya.TestHelper.get_one(JsonDataFaker.generate(schema)) || ""

    conn
    |> put_resp_content_type(content_type)
    |> send_resp(code, Quenya.ResponseHelper.encode(content_type, resp))
  end

  def get_header_schemas do
    {200, []}
  end

  def get_body_schemas do
    {200,
     %{
       "application/json" =>
         {"application/json",
          %ExJsonSchema.Schema.Root{
            custom_format_validator: nil,
            location: :root,
            refs: %{},
            schema: %{
              "description" => "Describes the result of uploading an image resource",
              "properties" => %{
                "code" => %{"format" => "int32", "type" => "integer"},
                "message" => %{"type" => "string"},
                "type" => %{"type" => "string"}
              },
              "title" => "An uploaded response",
              "type" => "object"
            }
          }}
     }}
  end
end
