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
      post_processors: [QuenyaTodo.Gen.DeleteTodo.ResponseValidator],
      handlers: []
    ]
  )

  get("/todo/:todoId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [QuenyaTodo.Gen.GetTodo.RequestValidator],
      post_processors: [QuenyaTodo.Gen.GetTodo.ResponseValidator],
      handlers: []
    ]
  )

  patch("/todo/:todoId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [QuenyaTodo.Gen.UpdateTodo.RequestValidator],
      post_processors: [QuenyaTodo.Gen.UpdateTodo.ResponseValidator],
      handlers: []
    ]
  )

  get("/todos",
    to: RoutePlug,
    init_opts: [
      preprocessors: [QuenyaTodo.Gen.ListTodos.RequestValidator],
      post_processors: [QuenyaTodo.Gen.ListTodos.ResponseValidator],
      handlers: []
    ]
  )

  post("/todos",
    to: RoutePlug,
    init_opts: [
      preprocessors: [QuenyaTodo.Gen.CreateTodo.RequestValidator],
      post_processors: [QuenyaTodo.Gen.CreateTodo.ResponseValidator],
      handlers: []
    ]
  )
end
