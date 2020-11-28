defmodule Todo.Gen.Router do
  @moduledoc false
  use Plug.Router
  use Plug.ErrorHandler
  require Logger
  alias QuenyaUtil.Plug.{RoutePlug, SwaggerPlug, MathAllPlug}
  plug(Plug.Static, at: "/public", from: {:quenya_util, "priv/swagger"})
  plug(Plug.Logger, log: :info)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  def handle_errors(conn, %{kind: _kind, reason: %{message: msg} = reason, stack: _stack}) do
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

  get("/swagger/main.json", to: SwaggerPlug, init_opts: [app: :todo])
  get("/swagger", to: SwaggerPlug, init_opts: [spec: "/swagger/main.json"])

  delete("/todo/:todoId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [Todo.Gen.DeleteTodo.RequestValidator],
      postprocessors: [],
      handlers: [Todo.Gen.DeleteTodo.FakeHandler]
    ]
  )

  get("/todo/:todoId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [Todo.Gen.GetTodo.RequestValidator],
      postprocessors: [],
      handlers: [Todo.Gen.GetTodo.FakeHandler]
    ]
  )

  patch("/todo/:todoId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [Todo.Gen.UpdateTodo.RequestValidator],
      postprocessors: [],
      handlers: [Todo.Gen.UpdateTodo.FakeHandler]
    ]
  )

  get("/todos",
    to: RoutePlug,
    init_opts: [
      preprocessors: [Todo.Gen.ListTodos.RequestValidator],
      postprocessors: [],
      handlers: [Todo.Gen.ListTodos.FakeHandler]
    ]
  )

  post("/todos",
    to: RoutePlug,
    init_opts: [
      preprocessors: [Todo.Gen.CreateTodo.RequestValidator],
      postprocessors: [],
      handlers: [Todo.Gen.CreateTodo.FakeHandler]
    ]
  )

  match(_, to: MathAllPlug, init_opts: [])
end
