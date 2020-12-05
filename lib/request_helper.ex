defmodule Quenya.RequestHelper do
  @moduledoc """
  Request helper functions
  """

  alias Quenya.Token
  alias Plug.Conn

  def validate_required(v, required?, position) do
    case {required?, v} do
      {true, nil} -> raise(Plug.BadRequestError, "#{v} does not exist in request #{position}")
      _ -> v
    end
  end

  def get_param(conn, name, "path", schema), do: normalize_param(conn.path_params[name], schema)
  def get_param(conn, name, "query", schema), do: normalize_param(conn.query_params[name], schema)

  def get_param(conn, name, position, schema) when position in ["header", "resp_header"] do
    headers =
      case position do
        "header" -> conn.req_headers
        "resp_header" -> conn.resp_headers
      end

    name = String.downcase(name)

    v =
      Enum.reduce_while(headers, nil, fn {k, v}, _acc ->
        case k == name do
          true -> {:halt, v}
          _ -> {:cont, nil}
        end
      end)

    normalize_param(v, schema)
  end

  def get_param(conn, name, "cookie", schema), do: normalize_param(conn.cookies[name], schema)

  def get_content_type(conn, position) do
    v = get_param(conn, "content-type", position, nil) || ""
    [result | _] = String.split(v, ";")
    result
  end

  def get_accept(conn) do
    (get_param(conn, "accept", "header", nil) || "*/*")
    |> String.split(",")
    |> Enum.map(fn part ->
      [result | _] = part |> String.trim() |> String.split(";")
      result
    end)
  end

  def put_security_scheme(conn, nil), do: conn

  def put_security_scheme(conn, {%{type: "http", scheme: "bearer", bearerFormat: "JWT"}, _opts}) do
    {token, _} = Token.create_access_token(%{id: 1})
    conn |> Conn.put_req_header("authorization", "Bearer #{token}")
  end

  def put_security_scheme(_conn, {%{type: "apiKey", name: _name, position: _position}, _opts}) do
    raise "Not implemented for apiKey"
  end

  def put_security_scheme(_conn, {scheme, _opts}),
    do: raise("Not supported scheme #{inspect(scheme)}")

  # private functions
  defp normalize_param(nil, _schema), do: nil

  defp normalize_param(v, %{"type" => "array"} = _schema) do
    String.split(v, ",")
  end

  defp normalize_param(v, %{"type" => "integer"} = _schema) do
    case Integer.parse(v) do
      {r, ""} -> r
      _ -> v
    end
  end

  defp normalize_param(v, _schema), do: v
end
