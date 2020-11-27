defmodule QuenyaTodo.Gen.GetTodo.RequestValidator do
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

    data = [
      {"todoId", "path", true,
       {:%{}, [],
        [
          __struct__: ExJsonSchema.Schema.Root,
          custom_format_validator: nil,
          location: :root,
          refs: {:%{}, [], []},
          schema: {:%{}, [], [{"format", "uuid"}, {"type", "string"}]}
        ]}}
    ]

    context =
      Enum.reduce(data, context, fn {name, position, required, schema}, acc ->
        v = RequestHelper.get_param(conn, name, position)

        if(required) do
          RequestHelper.validate_required(v, required, position)
        end

        v = v || schema.schema["default"]

        case(Validator.validate(schema, v)) do
          {:error, [{msg, _} | _]} ->
            raise(Plug.BadRequestError, msg)

          :ok ->
            Map.put(acc, name, v)
        end
      end)

    Plug.Conn.assign(conn, :request_context, context)
  end
end
