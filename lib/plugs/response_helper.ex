defmodule Quenya.ResponseHelper do
  @moduledoc """
  Helper function for response
  """

  def encode("application/json", data), do: Jason.encode!(data)

  def encode(content_type, _data),
    do: raise(Plug.BadRequestError, "Content type #{inspect(content_type)} not supported")
end
