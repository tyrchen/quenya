defmodule Quenya.Builder.Response do
  @moduledoc """
  Build response validator module

  Usage:

  ```elixir
  {:ok, root} = Quenya.Parser.parse("todo.yml")
  doc = root["paths"]["/todos"]["get"]
  # generate response validator for GET /todos
  Quenya.Builder.Response.gen(doc, :awesome_app, "listTodos")
  ```
  """
  require DynamicModule

  alias Quenya.Builder.Util
  alias ExJsonSchema.Schema

  def gen(doc, app, name, opts \\ []) do
    IO.puts("generating request validator for  #{name}")

    mod_name = Util.gen_response_validator_name(app, name)

    preamble = gen_preamble()

    header_validator = gen_header_validators(doc["responses"])
    body_validator = gen_body_validators(doc["responses"])

    contents =
      quote do
        def validate(conn) do
          unquote(header_validator)
          unquote(body_validator)
          conn
        end
      end

    DynamicModule.gen(mod_name, preamble, contents, opts)
  end

  defp gen_preamble do
    quote do
      require Logger
      alias ExJsonSchema.Validator
      alias QuenyaUtil.RequestHelper
      alias Plug.Conn

      def init(opts) do
        opts
      end
    end
  end

  defp gen_header_validators(nil), do: nil

  defp gen_header_validators(resp) do
    schemas =
      Enum.reduce(resp, %{}, fn {code, body}, acc1 ->
        result1 =
          Enum.reduce(body["headers"] || %{}, %{}, fn {header_name, v}, acc2 ->
            result2 = Schema.resolve(v["schema"])
            Map.put(acc2, header_name, {result2, v["required"] || false})
          end)

        Map.put(acc1, code, result1)
      end)
      |> Macro.escape()

    quote bind_quoted: [schemas: schemas] do
      schemas_with_code = schemas[Integer.to_string(conn.status)] || schemas["default"]

      Enum.map(schemas_with_code, fn {name, {schema, required}} ->
        v = RequestHelper.get_param(conn, name, "resp_header")
        if required, do: RequestHelper.validate_required(v, required, "resp_header")

        case Validator.validate(schema, v) do
          {:error, [{msg, _} | _]} -> raise(Plug.BadRequestError, msg)
          :ok -> :ok
        end
      end)
    end
  end

  defp gen_body_validators(nil) do
    quote do
    end
  end

  defp gen_body_validators(resp) do
    schemas =
      Enum.reduce(resp, %{}, fn {code, body}, acc1 ->
        result1 =
          Enum.reduce(body["content"] || %{}, %{}, fn {k, v}, acc2 ->
            result2 = Schema.resolve(v["schema"])
            Map.put(acc2, k, result2)
          end)

        Map.put(acc1, code, result1)
      end)
      |> Macro.escape()

    quote bind_quoted: [schemas: schemas] do
      accepts = RequestHelper.get_accept(conn)
      schemas_with_code = schemas[Integer.to_string(conn.status)] || schemas["default"]

      schema =
        Enum.reduce_while(accepts, nil, fn type, acc ->
          case Map.get(schemas_with_code, type) do
            nil -> {:cont, nil}
            v -> {:halt, v}
          end
        end) || schemas_with_code["application/json"] ||
          raise(
            Plug.BadRequestError,
            "accept content type #{inspect(accepts)} is not supported"
          )

      data = conn.resp_body

      case Validator.validate(schema, data) do
        {:error, [{msg, _} | _]} -> raise(Plug.BadRequestError, msg)
        :ok -> :ok
      end
    end
  end
end
