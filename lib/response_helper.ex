defmodule Quenya.ResponseHelper do
  @moduledoc """
  Helper functions for response
  """

  def decode("application/json", body), do: Jason.decode!(body)
  def decode("*/*", body), do: body

  def decode(content_type, _body),
    do: raise("Content type #{inspect(content_type)} not supported")

  def encode("application/json", data), do: Jason.encode!(data)

  def encode(content_type, _data),
    do: raise(Plug.BadRequestError, "Content type #{inspect(content_type)} not supported")

  def choose_best_response(schemas) do
    case schemas["200"] do
      nil ->
        status =
          schemas
          |> Map.keys()
          |> Enum.reduce_while(nil, fn item, _acc ->
            case item do
              "2" <> _ -> {:halt, item}
              _ -> {:cont, item}
            end
          end) || "200"

        code =
          case status do
            "default" -> 200
            _ -> String.to_integer(status)
          end

        {code, schemas[status]}

      v ->
        {200, v}
    end
  end
end
