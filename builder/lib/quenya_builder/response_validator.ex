defmodule QuenyaBuilder.ResponseValidator do
  @moduledoc """
  Build response validator module
  ```
  """
  require DynamicModule

  alias QuenyaBuilder.Util

  def gen(res, app, name, opts \\ []) do
    mod_name = Util.gen_response_validator_name(app, name)

    preamble = gen_preamble()

    header_schemas = Util.shrink_response_data(res, "headers")
    body_schemas = Util.shrink_response_data(res, "content")

    header_validator = gen_header()
    body_validator = gen_body()

    contents =
      quote do
        def call(conn, _opts) do
          unquote(header_validator)
          unquote(body_validator)
          conn
        end

        def get_header_schemas, do: unquote(header_schemas)
        def get_body_schemas, do: unquote(body_schemas)
      end

    DynamicModule.gen(mod_name, preamble, contents, opts)
  end

  defp gen_preamble do
    quote do
      require Logger

      alias ExJsonSchema.Validator
      alias Quenya.RequestHelper

      def init(opts) do
        opts
      end
    end
  end

  defp gen_header do
    quote do
      schemas = get_header_schemas()
      schemas_with_code = schemas[Integer.to_string(conn.status)] || schemas["default"]

      Enum.reduce_while(schemas_with_code, :ok, fn {name, {_, schema, required}}, _acc ->
        v = RequestHelper.get_param(conn, name, "resp_header", schema.schema)
        if required, do: RequestHelper.validate_required(v, required, "resp_header")

        case Validator.validate(schema, v) do
          {:error, [{msg, _} | _]} ->
            {:halt,
             raise("Failed to validate header #{name} with value: #{inspect(v)}. Errors: #{msg}")}

          :ok ->
            {:cont, :ok}
        end
      end)
    end
  end

  defp gen_body do
    quote do
      schemas = get_body_schemas()
      schemas_with_code = schemas[Integer.to_string(conn.status)] || schemas["default"]
      content_type = Quenya.RequestHelper.get_content_type(conn, "resp_header")

      {_type, schema, _} =
        case Map.get(schemas_with_code, content_type) do
          nil -> {content_type, nil, false}
          v -> v
        end

      accepts = Quenya.RequestHelper.get_accept(conn)

      Enum.reduce_while(accepts, :ok, fn type, _acc ->
        case String.contains?(type, content_type) or String.contains?(type, "*/*") do
          true ->
            {:halt, :ok}

          _ ->
            {:halt,
             raise(
               "accept content type #{inspect(type)} is not the same as content type #{
                 content_type
               }"
             )}
        end
      end)

      if schema != nil do
        case Quenya.ResponseHelper.decode(content_type, conn.resp_body) do
          "" ->
            :ok

          v ->
            case Validator.validate(schema, v) do
              {:error, [{msg, _} | _]} ->
                raise("Failed to validate body with value: #{inspect(v)}. Errors: #{msg}")

              :ok ->
                :ok
            end
        end
      end
    end
  end
end
