defmodule QuenyaTodo.Gen.Router do
  @moduledoc false
  use Plug.Router
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)
  plug(:dispatch)

  delete("/todo/:todoId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [QuenyaTodo.Gen.DeleteTodo.RequestValidator],
      postprocessors: [QuenyaTodo.Gen.DeleteTodo.ResponseValidator],
      handlers: [QuenyaTodo.Gen.DeleteTodo.FakeHandler]
    ]
  )

  get("/todo/:todoId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [QuenyaTodo.Gen.GetTodo.RequestValidator],
      postprocessors: [QuenyaTodo.Gen.GetTodo.ResponseValidator],
      handlers: [QuenyaTodo.Gen.GetTodo.FakeHandler]
    ]
  )

  patch("/todo/:todoId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [QuenyaTodo.Gen.UpdateTodo.RequestValidator],
      postprocessors: [QuenyaTodo.Gen.UpdateTodo.ResponseValidator],
      handlers: [QuenyaTodo.Gen.UpdateTodo.FakeHandler]
    ]
  )

  get("/todos",
    to: RoutePlug,
    init_opts: [
      preprocessors: [QuenyaTodo.Gen.ListTodos.RequestValidator],
      postprocessors: [QuenyaTodo.Gen.ListTodos.ResponseValidator],
      handlers: [QuenyaTodo.Gen.ListTodos.FakeHandler]
    ]
  )

  post("/todos",
    to: RoutePlug,
    init_opts: [
      preprocessors: [QuenyaTodo.Gen.CreateTodo.RequestValidator],
      postprocessors: [QuenyaTodo.Gen.CreateTodo.ResponseValidator],
      handlers: [QuenyaTodo.Gen.CreateTodo.FakeHandler]
    ]
  )
end
