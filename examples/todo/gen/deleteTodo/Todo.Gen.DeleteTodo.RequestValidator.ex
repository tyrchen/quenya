defmodule Todo.Gen.DeleteTodo.RequestValidator do
  @moduledoc false
  require Logger
  alias ExJsonSchema.Validator
  alias QuenyaUtil.RequestHelper
  alias Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    context = %{}

    Conn.assign(conn, :request_context, context)
  end
end
