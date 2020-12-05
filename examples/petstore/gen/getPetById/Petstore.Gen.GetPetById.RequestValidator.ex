defmodule Petstore.Gen.GetPetById.RequestValidator do
  @moduledoc false
  require Logger
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    context = %{}
    data = get_params()

    context =
      Enum.reduce(data, context, fn {name, position, required, schema}, acc ->
        v = Quenya.RequestHelper.get_param(conn, name, position, schema.schema)

        if(required) do
          Quenya.RequestHelper.validate_required(v, required, position)
        end

        v = v || schema.schema["default"]

        case(ExJsonSchema.Validator.validate(schema, v)) do
          {:error, [{msg, _} | _]} ->
            raise(Plug.BadRequestError, msg)

          :ok ->
            Map.put(acc, name, v)
        end
      end)

    assign(conn, :request_context, context)
  end

  def get_params do
    [
      {"petId", "path", true,
       %ExJsonSchema.Schema.Root{
         custom_format_validator: nil,
         location: :root,
         refs: %{},
         schema: %{"format" => "int64", "type" => "integer"}
       }}
    ]
  end

  def get_body_schemas do
    %{}
  end
end
