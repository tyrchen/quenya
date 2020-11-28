defmodule Quenya.Builder.RequestValidator do
  @moduledoc """
  Build request validator module

  Usage:

  ```elixir
  {:ok, root} = Quenya.Parser.parse("todo.yml")
  doc = root["paths"]["/todos"]["get"]
  # generate request validator for GET /todos
  Quenya.Builder.Request.gen(doc, :awesome_app, "listTodos")
  ```
  """
  require DynamicModule

  alias Quenya.Builder.Util
  alias ExJsonSchema.Schema

  def gen(doc, app, name, opts \\ []) do
    mod_name = Util.gen_request_validator_name(app, name)

    preamble = gen_preamble()

    param_validator = gen_parameter_validator(doc["parameters"])
    body_validator = gen_body_validator(doc["requestBody"])

    contents =
      quote do
        def call(conn, _opts) do
          context = %{}
          unquote(param_validator)
          unquote(body_validator)
          Conn.assign(conn, :request_context, context)
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

  defp gen_parameter_validator(nil) do
    quote do
    end
  end

  defp gen_parameter_validator(params) do
    data =
      params
      |> Enum.map(fn p ->
        name = p["name"]

        position = Util.ensure_position(p["in"])
        required = p["required"] || false
        schema = p["schema"] |> Schema.resolve()
        {name, position, required, schema}
      end)
      |> Macro.escape()

    quote bind_quoted: [data: data] do
      context =
        Enum.reduce(data, context, fn {name, position, required, schema}, acc ->
          v = RequestHelper.get_param(conn, name, position, schema.schema)

          if required, do: RequestHelper.validate_required(v, required, position)

          # add default value if v is null
          v = v || schema.schema["default"]

          case Validator.validate(schema, v) do
            {:error, [{msg, _} | _]} -> raise(Plug.BadRequestError, msg)
            :ok -> Map.put(acc, name, v)
          end
        end)
    end
  end

  defp gen_body_validator(nil) do
    quote do
    end
  end

  defp gen_body_validator(body) do
    schemas =
      Enum.reduce(body["content"], %{}, fn {k, v}, acc ->
        result = Schema.resolve(v["schema"])
        Map.put(acc, k, result)
      end)
      |> Macro.escape()

    quote bind_quoted: [schemas: schemas] do
      content_type = RequestHelper.get_content_type(conn)
      data = conn.body_params

      schema =
        schemas[content_type] ||
          raise(
            Plug.BadRequestError,
            "Unsupported request content type #{content_type}. Supported content type: #{
              inspect(Map.keys(schemas))
            }"
          )

      case Validator.validate(schema, data) do
        {:error, [{msg, _} | _]} -> raise(Plug.BadRequestError, msg)
        :ok -> :ok
      end
    end
  end
end
