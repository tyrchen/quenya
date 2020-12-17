defmodule QuenyaBuilder.Generator.RequestValidator do
  @moduledoc """
  Build request validator module
  """
  require DynamicModule

  alias QuenyaBuilder.Util

  def gen(req, params, app, name, opts \\ []) do
    mod_name = Util.gen_request_validator_name(app, name)

    preamble = gen_preamble()

    param_data = Enum.map(params, fn p -> {p.name, p.position, p.required, p.schema} end)
    body_schemas = Enum.reduce(req.content, %{}, fn {k, v}, acc -> Map.put(acc, k, v.schema) end)

    param_validator =
      case param_data do
        [] ->
          quote do
          end

        _ ->
          gen_parameter_validator()
      end

    body_validator =
      case body_schemas do
        v when v == %{} ->
          quote do
          end

        _ ->
          gen_body_validator()
      end

    contents =
      quote do
        def call(conn, _opts) do
          context = conn.assigns[:request_context] || %{}
          unquote(param_validator)
          unquote(body_validator)
          assign(conn, :request_context, context)
        end

        def get_params, do: unquote(param_data)
        def get_body_schemas, do: unquote(body_schemas)
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

  defp gen_parameter_validator do
    quote do
      data = get_params()

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

  defp gen_body_validator do
    quote do
      content_type = Quenya.RequestHelper.get_content_type(conn, "header")
      schemas = get_body_schemas()

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

      context = Map.put(context, "_body", data)
    end
  end
end
