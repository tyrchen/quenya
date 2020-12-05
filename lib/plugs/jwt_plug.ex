defmodule Quenya.Plug.JwtPlug do
  @moduledoc """
  JWT plug to handle the JWT bearer token
  """

  import Plug.Conn

  alias Quenya.Plug.{UnauthenticatedError, UnauthorizedError}

  alias Quenya.Token

  @behaviour Plug

  @spec init(keyword()) :: keyword()
  def init(opts) do
    opts
  end

  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        verify_token(conn, token)

      v ->
        raise(
          UnauthenticatedError,
          "Expected a bearer token in the `authorization` header. Got #{inspect(v)}"
        )
    end
  end

  defp verify_token(conn, token) do
    with {:ok, claims} <- Token.verify_and_validate(token),
         {:ok, valid_claims} <- verify_claims(claims) do
      assign(conn, :request_context, %{auth: valid_claims})
    else
      {:error, :invalid_token_type} ->
        raise(UnauthenticatedError, "Invalid token. Expected an access token.")

      {:error, error} ->
        raise(UnauthorizedError, "Token is invalid. Error: #{inspect(error)}")
    end
  end

  defp verify_claims(claims) do
    case Token.is_access_token(claims) do
      true -> {:ok, claims}
      _ -> {:error, :invalid_token_type}
    end
  end
end
