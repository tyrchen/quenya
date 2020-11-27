defmodule QuenyaTodo.Gen.ListTodos.RequestValidator do
  @moduledoc false
  alias ExJsonSchema.Validator
  require Logger
  alias QuenyaUtil.RequestHelper

  def validate(conn) do
    name = "limit"
    position = "query"
    required = false

    schema = %{
      __struct__: ExJsonSchema.Schema.Root,
      custom_format_validator: nil,
      location: :root,
      refs: %{},
      schema: %{
        "default" => 10,
        "format" => "int32",
        "maximum" => 100,
        "minimum" => 10,
        "type" => "integer"
      }
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

    name = "filter"
    position = "query"
    required = false

    schema = %{
      __struct__: ExJsonSchema.Schema.Root,
      custom_format_validator: nil,
      location: :root,
      refs: %{},
      schema: %{"default" => "all", "enum" => ["all", "active", "completed"], "type" => "string"}
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
