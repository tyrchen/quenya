defmodule QuenyaTodo.Gen.UpdateTodo.RequestValidator do
  @moduledoc false
  require Logger
  alias ExJsonSchema.Validator
  alias QuenyaUtil.RequestHelper
  alias Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    context = %{}

    schemas = %{
      "application/json" => %{
        __struct__: ExJsonSchema.Schema.Root,
        custom_format_validator: nil,
        location: :root,
        refs: %{},
        schema: %{
          "properties" => %{"status" => %{"enum" => ["active", "completed"], "type" => "string"}},
          "type" => "object"
        }
      }
    }

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

    case(Validator.validate(schema, data)) do
      {:error, [{msg, _} | _]} ->
        raise(Plug.BadRequestError, msg)

      :ok ->
        :ok
    end

    Conn.assign(conn, :request_context, context)
  end
end
