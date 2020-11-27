defmodule QuenyaTodo.Gen.GetTodo.RequestValidator do
  @moduledoc false
  alias ExJsonSchema.Validator
  require Logger
  alias QuenyaUtil.RequestHelper

  def validate(conn) do
    name = "todoId"
    position = "path"
    required = true

    schema = %{
      __struct__: ExJsonSchema.Schema.Root,
      custom_format_validator: nil,
      location: :root,
      refs: %{},
      schema: %{"format" => "uuid", "type" => "string"}
    }

    v = RequestHelper.get_param(conn, name, position)

    if(required) do
      RequestHelper.validate_required(v, required, position)
    end

    v = v || schema.schema["default"]

    case(Validator.validate(schema, v)) do
      {:error, [{msg, _} | _]} ->
        raise(Plug.BadRequestError, msg)

      :ok ->
        :ok
    end

    :ok
  end
end
