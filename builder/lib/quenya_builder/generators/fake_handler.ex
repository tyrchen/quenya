defmodule QuenyaBuilder.Generator.FakeHandler do
  @moduledoc """
  Generate fake handler for response
  """
  require DynamicModule

  alias QuenyaBuilder.Util
  alias Quenya.ResponseHelper

  def gen(res, app, name, opts \\ []) do
    mod_name = Util.gen_fake_handler_name(app, name)

    preamble = gen_preamble()

    {code, data} = ResponseHelper.choose_best_response(res)
    header_schemas = Enum.map(data.headers, fn {k, v} -> {k, v.schema, v.required} end)

    body_schemas =
      Enum.reduce(data.content, %{}, fn {k, v}, acc2 ->
        Map.put(acc2, k, {k, v.schema})
      end)

    header =
      case header_schemas do
        v when v == %{} ->
          quote do
          end

        _ ->
          gen_header()
      end

    body =
      case body_schemas do
        v when v == %{} ->
          quote do
            send_resp(conn, unquote(code), "")
          end

        _ ->
          gen_body()
      end

    contents =
      quote do
        def call(conn, _opts) do
          unquote(header)
          unquote(body)
        end

        def get_header_schemas, do: {unquote(code), unquote(header_schemas)}
        def get_body_schemas, do: {unquote(code), unquote(body_schemas)}
      end

    DynamicModule.gen(mod_name, preamble, contents, opts)
  end

  defp gen_preamble do
    quote do
      require Logger
      import Plug.Conn

      def init(opts) do
        opts
      end
    end
  end

  defp gen_header do
    quote do
      {_, schemas} = get_header_schemas()

      conn =
        Enum.reduce(schemas, conn, fn {name, schema, _required}, acc ->
          v =
            case Quenya.TestHelper.get_one(JsonDataFaker.generate(schema)) do
              v when is_binary(v) -> v
              v when is_integer(v) -> Integer.to_string(v)
              v -> "#{inspect(v)}"
            end

          Plug.Conn.put_resp_header(acc, name, v)
        end)
    end
  end

  defp gen_body do
    quote do
      {code, schemas} = get_body_schemas()
      accepts = Quenya.RequestHelper.get_accept(conn)

      {content_type, schema} =
        Enum.reduce_while(accepts, nil, fn type, _acc ->
          case(Map.get(schemas, type)) do
            nil -> {:cont, nil}
            v -> {:halt, v}
          end
        end) || schemas["application/json"] ||
          raise(
            Plug.BadRequestError,
            "accept content type #{inspect(accepts)} is not supported"
          )

      resp = Quenya.TestHelper.get_one(JsonDataFaker.generate(schema)) || ""

      conn
      |> put_resp_content_type(content_type)
      |> send_resp(code, Quenya.ResponseHelper.encode(content_type, resp))
    end
  end
end
