defmodule QuenyaTodo.Gen.CreateTodo.RequestValidator do
  @moduledoc false
  alias ExJsonSchema.Validator
  require Logger
  alias QuenyaUtil.RequestHelper

  def validate(conn) do
    schemas = %{
      "application/json" => %{
        __struct__: ExJsonSchema.Schema.Root,
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

    :ok
  end
end
