defmodule Todo.Gen.ApiRouter do
  @moduledoc false
  use Plug.Router
  use Plug.ErrorHandler
  require Logger
  alias Quenya.Plug.{RoutePlug, MathAllPlug}

  plug :match

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["application/json"],
    json_decoder: Jason

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

  delete("/todo/:todoId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Quenya.Plug.JwtPlug, []}, {Todo.Gen.DeleteTodo.RequestValidator, []}],
      handlers: [{Todo.Gen.DeleteTodo.FakeHandler, []}],
      postprocessors: [{Todo.Gen.DeleteTodo.ResponseValidator, []}]
    ]
  )

  get("/todo/:todoId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Todo.Gen.GetTodo.RequestValidator, []}],
      handlers: [{Todo.Gen.GetTodo.FakeHandler, []}],
      postprocessors: [{Todo.Gen.GetTodo.ResponseValidator, []}]
    ]
  )

  patch("/todo/:todoId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Quenya.Plug.JwtPlug, []}, {Todo.Gen.UpdateTodo.RequestValidator, []}],
      handlers: [{Todo.Gen.UpdateTodo.FakeHandler, []}],
      postprocessors: [{Todo.Gen.UpdateTodo.ResponseValidator, []}]
    ]
  )

  get("/todos",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Todo.Gen.ListTodos.RequestValidator, []}],
      handlers: [{Todo.Gen.ListTodos.FakeHandler, []}],
      postprocessors: [{Todo.Gen.ListTodos.ResponseValidator, []}]
    ]
  )

  post("/todos",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Quenya.Plug.JwtPlug, []}, {Todo.Gen.CreateTodo.RequestValidator, []}],
      handlers: [{Todo.Gen.CreateTodo.FakeHandler, []}],
      postprocessors: [{Todo.Gen.CreateTodo.ResponseValidator, []}]
    ]
  )

  match(_, to: MathAllPlug, init_opts: [])
end
