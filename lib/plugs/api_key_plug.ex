defmodule Quenya.Plug.ApiKeyPlug do
  @moduledoc """
  ApiKey plug to handle authentication with API key
  """

  import Plug.Conn

  alias Quenya.Plug.UnauthenticatedError

  @behaviour Plug

  @spec init(keyword()) :: keyword()
  def init(opts) do
    opts
  end

  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, opts) do
    case get_req_header(conn, opts[:api_key]) do
      [v] ->
        verify_api_key(conn, v)

      [] ->
        raise(
          UnauthenticatedError,
          "Expected an API key in the `authorization` header. Got nothing."
        )
    end
  end

  defp verify_api_key(conn, _value) do
    conn
  end
end
