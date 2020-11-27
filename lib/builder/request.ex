defmodule Quenya.Builder.Request do
  @moduledoc """
  Build request validator module

  Usage:

  ```elixir
  {:ok, root} = Quenya.Parser.parse("todo.yml")
  # generate request validator for POST /todos
  Quenya.Builder.Request.gen(root, "/todos", "post")
  ```
  """
  require DynamicModule

  alias Quenya.Builder.Util
  alias ExJsonSchema.Schema

  def gen(doc, app, name, opts \\ []) do
    IO.puts("generating request validator for  #{name}")

    mod_name = Util.gen_request_validator_name(app, name)

    preamble = gen_preamble()

    param_validators = gen_parameter_validator(doc["parameters"])
    body_validators = gen_body_validator(doc["requestBody"])

    contents =
      quote do
        def validate(conn) do
          (unquote_splicing(param_validators ++ body_validators))
          :ok
        end
      end

    DynamicModule.gen(mod_name, preamble, contents, opts)
  end

  defp gen_preamble do
    quote do
      alias ExJsonSchema.Validator
      require Logger
      alias QuenyaUtil.RequestHelper
    end
  end

  defp gen_parameter_validator(nil), do: []

  defp gen_parameter_validator(params) do
    Enum.map(params, fn p ->
      name = p["name"]

      position = Util.ensure_position(p["in"])
      required = p["required"] || false
      schema = p["schema"] |> Schema.resolve() |> Macro.escape()

      quote bind_quoted: [name: name, position: position, required: required, schema: schema] do
        v = RequestHelper.get_param(conn, name, position)
        if required, do: RequestHelper.validate_required(v, required, position)

        # add default value if v is null
        v = v || schema.schema["default"]

        case Validator.validate(schema, v) do
          {:error, [{msg, _} | _]} -> raise(Plug.BadRequestError, msg)
          :ok -> :ok
        end
      end
    end)
  end

  defp gen_body_validator(nil), do: []

  defp gen_body_validator(body) do
    schemas =
      Enum.reduce(body["content"], %{}, fn {k, v}, acc ->
        result = Schema.resolve(v["schema"])
        Map.put(acc, k, result)
      end)
      |> Macro.escape()

    [
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
    ]
  end
end
