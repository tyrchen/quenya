defmodule Quenya.Plug.MathAllPlug do
  @moduledoc """
  Plug for match all unknown path

  Example:

      # in your router file

      match _, to: Quenya.Plug.MathAllPlug, init_opts: []
  """

  import Plug.Conn

  @behaviour Plug

  @spec init(keyword()) :: keyword()
  def init(opts) do
    opts
  end

  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, _opts) do
    send_resp(conn, 404, "requested path #{conn.request_path} not found")
  end
end
