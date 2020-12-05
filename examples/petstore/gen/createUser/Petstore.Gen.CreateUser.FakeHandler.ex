defmodule Petstore.Gen.CreateUser.FakeHandler do
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

    send_resp(conn, 201, "")
  end

  def get_header_schemas do
    {201, []}
  end

  def get_body_schemas do
    {201, %{}}
  end
end
