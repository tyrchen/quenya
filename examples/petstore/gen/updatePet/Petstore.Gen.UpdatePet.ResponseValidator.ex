defmodule Petstore.Gen.UpdatePet.ResponseValidator do
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
    %{"200" => %{}, "400" => %{}, "404" => %{}, "405" => %{}}
  end

  def get_body_schemas do
    %{
      "200" => %{
        "application/json" =>
          {"application/json",
           %ExJsonSchema.Schema.Root{
             custom_format_validator: nil,
             location: :root,
             refs: %{},
             schema: %{
               "description" => "A pet for sale in the pet store",
               "properties" => %{
                 "category" => %{
                   "description" => "A category for a pet",
                   "properties" => %{
                     "id" => %{"format" => "int64", "type" => "integer"},
                     "name" => %{
                       "pattern" => "^[a-zA-Z0-9]+[a-zA-Z0-9\\.\\-_]*[a-zA-Z0-9]+$",
                       "type" => "string"
                     }
                   },
                   "title" => "Pet category",
                   "type" => "object"
                 },
                 "id" => %{"format" => "int64", "type" => "integer"},
                 "name" => %{"example" => "doggie", "pattern" => "^\\w+$", "type" => "string"},
                 "photoUrls" => %{
                   "items" => %{"format" => "image_uri", "type" => "string"},
                   "type" => "array"
                 },
                 "status" => %{
                   "description" => "pet status in the store",
                   "enum" => ["available", "pending", "sold"],
                   "type" => "string"
                 },
                 "tags" => %{
                   "items" => %{
                     "description" => "A tag for a pet",
                     "properties" => %{
                       "id" => %{"format" => "int64", "type" => "integer"},
                       "name" => %{"type" => "string"}
                     },
                     "title" => "Pet Tag",
                     "type" => "object"
                   },
                   "type" => "array"
                 }
               },
               "required" => ["name", "photoUrls"],
               "title" => "a Pet",
               "type" => "object"
             }
           }, false}
      },
      "400" => %{},
      "404" => %{},
      "405" => %{}
    }
  end
end
