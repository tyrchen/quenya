defmodule Petstore.Gen.DeletePet.ResponseValidator do
  @moduledoc false
  require Logger
  alias ExJsonSchema.Validator
  alias Quenya.RequestHelper

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    schemas = get_header_schemas()
    schemas_with_code = schemas[Integer.to_string(conn.status)] || schemas["default"]

    Enum.reduce_while(schemas_with_code, :ok, fn {name, {_, schema, required}}, _acc ->
      v = RequestHelper.get_param(conn, name, "resp_header", schema.schema)

      if(required) do
        RequestHelper.validate_required(v, required, "resp_header")
      end

      case(Validator.validate(schema, v)) do
        {:error, [{msg, _} | _]} ->
          {:halt,
           raise("Failed to validate header #{name} with value: #{inspect(v)}. Errors: #{msg}")}

        :ok ->
          {:cont, :ok}
      end
    end)

    schemas = get_body_schemas()
    schemas_with_code = schemas[Integer.to_string(conn.status)] || schemas["default"]
    content_type = Quenya.RequestHelper.get_content_type(conn, "resp_header")

    {_type, schema, _} =
      case(Map.get(schemas_with_code, content_type)) do
        nil ->
          {content_type, nil, false}

        v ->
          v
      end

    accepts = Quenya.RequestHelper.get_accept(conn)

    _ =
      Enum.reduce_while(accepts, :ok, fn type, _acc ->
        case(String.contains?(type, content_type) or String.contains?(type, "*/*")) do
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

    if(schema != nil) do
      case(Quenya.ResponseHelper.decode(content_type, conn.resp_body)) do
        "" ->
          :ok

        v ->
          case(Validator.validate(schema, v)) do
            {:error, [{msg, _} | _]} ->
              raise("Failed to validate body with value: #{inspect(v)}. Errors: #{msg}")

            :ok ->
              :ok
          end
      end
    end

    conn
  end

  def get_header_schemas do
    %{"204" => %{}, "400" => %{}}
  end

  def get_body_schemas do
    %{"204" => %{}, "400" => %{}}
  end
end
