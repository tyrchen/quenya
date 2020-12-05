defmodule Todo.Gen.CreateTodo.RequestValidator do
  @moduledoc false
  require Logger
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    context = conn.assigns[:request_context]

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
          "properties" => %{
            "body" => %{"maxLength" => 140, "minLength" => 3, "type" => "string"},
            "title" => %{"maxLength" => 64, "minLength" => 3, "type" => "string"}
          },
          "required" => ["title"],
          "type" => "object"
        }
      }
    }
  end
end
