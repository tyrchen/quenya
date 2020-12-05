defmodule Petstore.Gen.AddPet.RequestValidator do
  @moduledoc false
  require Logger
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    context = conn.assigns[:request_context] || %{}

    content_type = Quenya.RequestHelper.get_content_type(conn, "header")
    schemas = get_body_schemas()

    data =
      case(Map.get(conn.body_params, "_json")) do
        nil ->
          conn.body_params

        v ->
          v
      end

    schema =
      schemas[content_type] ||
        raise(
          Plug.BadRequestError,
          "Unsupported request content type #{content_type}. Supported content type: #{
            inspect(Map.keys(schemas))
          }"
        )

    case(ExJsonSchema.Validator.validate(schema, data)) do
      {:error, [{msg, _} | _]} ->
        raise(Plug.BadRequestError, msg)

      :ok ->
        :ok
    end

    assign(conn, :request_context, context)
  end

  def get_params do
    []
  end

  def get_body_schemas do
    %{
      "application/json" => %ExJsonSchema.Schema.Root{
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
      }
    }
  end
end
