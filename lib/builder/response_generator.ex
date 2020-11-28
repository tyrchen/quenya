defmodule Quenya.Builder.ResponseGenerator do
  @moduledoc """
  Generate fake handler for response
  """
  require DynamicModule
  alias Quenya.Builder.Util

  def gen(doc, app, name, opts \\ []) do
    IO.puts("generating fake handler for #{name}.")

    mod_name = Util.gen_fake_handler_name(app, name)

    preamble = gen_preamble()
    header = gen_header(doc["responses"])
    body = gen_body(doc["responses"])

    contents =
      quote do
        def validate(conn) do
          unquote(header)
          unquote(body)
        end
      end

    DynamicModule.gen(mod_name, preamble, contents, opts)
  end

  def gen_preamble do
    quote do
      require Logger
      alias QuenyaUtil.RequestHelper
      alias Plug.Conn

      def init(opts) do
        opts
      end
    end
  end

  defp gen_header(resp) do
    schemas = Util.get_response_schemas(resp, "headers")

    case Enum.empty?(schemas) do
      true ->
        quote do
        end

      _ ->
        quote bind_quoted: [schemas: schemas |> Macro.escape()] do
          schemas_with_code = schemas[Integer.to_string(conn.status)] || schemas["default"]

          conn =
            Enum.reduce(schemas_with_code, conn, fn {name, schema}, acc ->
              v = JsonDataFaker.generate(schema[:schema])
              Conn.put_resp_header(acc, name, v)
            end)
        end
    end
  end

  defp gen_body(resp) do
    schemas = Util.get_response_schemas(resp, "content")

    {code, schema} =
      case schemas["200"] do
        nil ->
          status =
            schemas
            |> Map.keys()
            |> Enum.reduce_while(nil, fn item, _acc ->
              case item do
                "2" <> _ -> {:halt, item}
                _ -> {:cont, item}
              end
            end)

          code =
            case status do
              "default" -> 200
              _ -> String.to_integer(status)
            end

          {code, schemas[status]}

        v ->
          {200, v}
      end

    case schema do
      nil ->
        quote do
        end

      _ ->
        quote bind_quoted: [schemas_with_code: Macro.escape(schema), code: code] do
          accepts = RequestHelper.get_accept(conn)

          {content_type, schema} =
            Enum.reduce_while(accepts, nil, fn type, acc ->
              case Map.get(schemas_with_code, type) do
                nil -> {:cont, {type, nil}}
                v -> {:halt, {type, v}}
              end
            end) || {"application/json", schemas_with_code["application/json"]} ||
              raise(
                Plug.BadRequestError,
                "accept content type #{inspect(accepts)} is not supported"
              )

          Plug.Conn.put_resp_content_type(conn, content_type)
          resp = JsonDataFaker.generate(schema[:schema]) || ""
          Plug.Conn.send_resp(conn, code, resp)
        end
    end
  end
end
