defmodule QuenyaBuilder.RequestValidator do
  @moduledoc """
  Build request validator module

  Usage:

  ```elixir
  {:ok, root} = Quenya.Parser.parse("todo.yml")
  doc = root["paths"]["/todos"]["get"]
  # generate request validator for GET /todos
  QuenyaBuilder.Request.gen(doc, :awesome_app, "listTodos")
  ```
  """
  require DynamicModule

  alias QuenyaBuilder.Util

  def gen(req, params, app, name, opts \\ []) do
    mod_name = Util.gen_request_validator_name(app, name)

    preamble = gen_preamble()

    param_validator = gen_parameter_validator(params)
    body_validator = gen_body_validator(req)

    contents =
      quote do
        def call(conn, _opts) do
          context = %{}
          unquote(param_validator)
          unquote(body_validator)
          assign(conn, :request_context, context)
        end
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

  defp gen_parameter_validator([]) do
    quote do
    end
  end

  defp gen_parameter_validator(params) do
    data =
      params
      |> Enum.map(fn p ->
        {p.name, p.position, p.required, p.schema}
      end)
      |> Macro.escape()

    quote bind_quoted: [data: data] do
      context =
        Enum.reduce(data, context, fn {name, position, required, schema}, acc ->
          v = Quenya.RequestHelper.get_param(conn, name, position, schema.schema)

          if required, do: Quenya.RequestHelper.validate_required(v, required, position)

          # add default value if v is null
          v = v || schema.schema["default"]

          case ExJsonSchema.Validator.validate(schema, v) do
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
      Enum.reduce(body.content, %{}, fn {k, v}, acc ->
        Map.put(acc, k, v.schema)
      end)

    case Enum.empty?(schemas) do
      true ->
        quote do
        end

      _ ->
        quote bind_quoted: [schemas: schemas |> Macro.escape()] do
          content_type = Quenya.RequestHelper.get_content_type(conn)

          data =
            case Map.get(conn.body_params, "_json") do
              nil -> conn.body_params
              v -> v
            end

          schema =
            schemas[content_type] ||
              raise(
                Plug.BadRequestError,
                "Unsupported request content type #{content_type}. Supported content type: #{
                  inspect(Map.keys(schemas))
                }"
              )

          case ExJsonSchema.Validator.validate(schema, data) do
            {:error, [{msg, _} | _]} -> raise(Plug.BadRequestError, msg)
            :ok -> :ok
          end
        end
    end
  end
end
