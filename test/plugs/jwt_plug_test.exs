defmodule QuenyaTest.Plug.JwtPlug do
  use ExUnit.Case
  use Plug.Test

  import Plug.Conn

  alias Quenya.Token
  alias Quenya.Plug.{JwtPlug, UnauthenticatedError, UnauthorizedError}

  test "valid jwt token should pass" do
    {token, _} = Token.create_access_token(%{user_id: 1, name: "Tyr"})

    conn =
      conn(:post, "/")
      |> put_req_header("authorization", "Bearer #{token}")
      |> JwtPlug.call([])

    claims = Token.verify_and_validate!(token)
    assert conn.assigns[:request_context][:auth] == claims
  end

  test "valid jwt with incorrect type should fail" do
    {token, _} = Token.create_refresh_token(%{user_id: 1, name: "Tyr"})

    assert_raise UnauthenticatedError, ~r/access token/, fn ->
      conn(:post, "/")
      |> put_req_header("authorization", "Bearer #{token}")
      |> JwtPlug.call([])
    end
  end

  test "invalid jwt should fail" do
    assert_raise UnauthorizedError, ~r/invalid/, fn ->
      conn(:post, "/")
      |> put_req_header("authorization", "Bearer this_is_a_bad_token")
      |> JwtPlug.call([])
    end
  end

  test "no authorization header should fail" do
    assert_raise UnauthenticatedError, ~r/`authorization` header/, fn ->
      conn(:post, "/")
      |> JwtPlug.call([])
    end
  end
end
