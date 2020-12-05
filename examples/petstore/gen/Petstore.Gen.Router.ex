defmodule Petstore.Gen.Router do
  @moduledoc false
  use Plug.Router
  use Plug.ErrorHandler
  require Logger
  alias Quenya.Plug.SwaggerPlug
  plug Plug.Logger, log: :info
  plug Plug.Static, at: "/public", from: {:quenya, "priv/swagger"}

  plug :match
  plug Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason
  plug :dispatch

  def handle_errors(conn, %{kind: _kind, reason: %{message: msg}, stack: _stack}) do
    Plug.Conn.send_resp(conn, conn.status, msg)
  end

  def handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    Logger.warn(
      "Internal error:\n kind: #{inspect(kind)}\n reason: #{inspect(reason)}\n stack: #{
        inspect(stack)
      }"
    )

    Plug.Conn.send_resp(conn, conn.status, "Internal server error")
  end

  get("/swagger/main.json", to: SwaggerPlug, init_opts: [app: :petstore])
  get("/swagger", to: SwaggerPlug, init_opts: [spec: "/swagger/main.json"])
  forward "/", to: Petstore.Gen.ApiRouter, init_opts: []
end
