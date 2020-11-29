defmodule QuenyaBuilder.ResponseGenerator do
  @moduledoc """
  Generate fake handler for response
  """
  require DynamicModule
  alias QuenyaBuilder.Util

  def gen(doc, app, name, opts \\ []) do
    mod_name = Util.gen_fake_handler_name(app, name)

    preamble = gen_preamble()
    header = gen_header(doc["responses"])
    body = gen_body(doc["responses"])

    contents =
      quote do
        def call(conn, _opts) do
          unquote(header)
          unquote(body)
        end
      end

    DynamicModule.gen(mod_name, preamble, contents, opts)
  end

  def gen_preamble do
    quote do
      require Logger
      import Plug.Conn

      alias Quenya.{RequestHelper, ResponseHelper}

      def init(opts) do
        opts
      end
    end
  end

  defp gen_header(resp) do
    schemas = Util.get_response_schemas(resp, "headers")
    {_code, schemas_with_code} = Util.choose_best_code_schema(schemas)

    case Enum.empty?(schemas) do
      true ->
        quote do
        end

      _ ->
        quote bind_quoted: [schemas_with_code: Macro.escape(schemas_with_code)] do
          conn =
            Enum.reduce(schemas_with_code, conn, fn {name, schema}, acc ->
              v = JsonDataFaker.generate(schema[:schema])
              put_resp_header(acc, name, v)
            end)
        end
    end
  end

  defp gen_body(resp) do
    schemas = Util.get_response_schemas(resp, "content")

    {code, schema} = Util.choose_best_code_schema(schemas)

    case schema do
      nil ->
        quote do
        end

      _ ->
        quote bind_quoted: [schemas_with_code: Macro.escape(schema), code: code] do
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
              raise(
                Plug.BadRequestError,
                "accept content type #{inspect(accepts)} is not supported"
              )

          content_type = Keyword.get(schema, :content_type, "application/json")
          resp = JsonDataFaker.generate(schema[:schema]) || ""

          conn
          |> put_resp_content_type(content_type)
          |> send_resp(code, ResponseHelper.encode(content_type, resp))
        end
    end
  end
end
