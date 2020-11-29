defmodule Quenya.Builder.ResponseValidator do
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

  def gen(doc, app, name, opts \\ []) do
    mod_name = Util.gen_response_validator_name(app, name)

    preamble = gen_preamble()

    header_validator = gen_header_validators(doc["responses"])
    body_validator = gen_body_validators(doc["responses"])

    contents =
      quote do
        def call(conn, _opts) do
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
      import Plug.Conn

      alias ExJsonSchema.Validator
      alias QuenyaUtil.RequestHelper

      def init(opts) do
        opts
      end
    end
  end

  defp gen_header_validators(nil) do
    quote do
    end
  end

  defp gen_header_validators(resp) do
    schemas = Util.get_response_schemas(resp, "headers")

    case Enum.empty?(schemas) do
      true ->
        quote do
        end

      _ ->
        quote bind_quoted: [schemas: schemas |> Macro.escape()] do
          schemas_with_code = schemas[Integer.to_string(conn.status)] || schemas["default"]

          Enum.map(schemas_with_code, fn {name, schema} ->
            v = RequestHelper.get_param(conn, name, "resp_header", schemas[:schema])
            required = schema[:required]
            if required, do: RequestHelper.validate_required(v, required, "resp_header")

            case Validator.validate(schema[:schema], v) do
              {:error, [{msg, _} | _]} -> raise(Plug.BadRequestError, msg)
              :ok -> :ok
            end
          end)
        end
    end
  end

  defp gen_body_validators(nil) do
    quote do
    end
  end

  defp gen_body_validators(resp) do
    schemas =
      Util.get_response_schemas(resp, "content")
      |> Macro.escape()

    quote bind_quoted: [schemas: schemas] do
      accepts = RequestHelper.get_accept(conn)
      schemas_with_code = schemas[Integer.to_string(conn.status)] || schemas["default"]

      schema =
        Enum.reduce_while(accepts, nil, fn type, _acc ->
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

      case Validator.validate(schema[:schema], data) do
        {:error, [{msg, _} | _]} -> raise(Plug.BadRequestError, msg)
        :ok -> :ok
      end
    end
  end
end
