defmodule Petstore.Gen.GetInventory.RequestValidator do
  @moduledoc false
  require Logger
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    context = %{}

    assign(conn, :request_context, context)
  end

  def get_params do
    []
  end

  def get_body_schemas do
    %{}
  end
end
