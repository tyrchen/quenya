defmodule Petstore.Gen.ApiRouter do
  @moduledoc false
  use Plug.Router
  use Plug.ErrorHandler
  require Logger
  alias Quenya.Plug.{RoutePlug, MathAllPlug}

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

  post("/pet",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.AddPet.RequestValidator, []}],
      handlers: [{Petstore.Gen.AddPet.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.AddPet.ResponseValidator, []}]
    ]
  )

  put("/pet",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.UpdatePet.RequestValidator, []}],
      handlers: [{Petstore.Gen.UpdatePet.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.UpdatePet.ResponseValidator, []}]
    ]
  )

  get("/pet/findByStatus",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.FindPetsByStatus.RequestValidator, []}],
      handlers: [{Petstore.Gen.FindPetsByStatus.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.FindPetsByStatus.ResponseValidator, []}]
    ]
  )

  get("/pet/findByTags",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.FindPetsByTags.RequestValidator, []}],
      handlers: [{Petstore.Gen.FindPetsByTags.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.FindPetsByTags.ResponseValidator, []}]
    ]
  )

  delete("/pet/:petId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.DeletePet.RequestValidator, []}],
      handlers: [{Petstore.Gen.DeletePet.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.DeletePet.ResponseValidator, []}]
    ]
  )

  get("/pet/:petId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.GetPetById.RequestValidator, []}],
      handlers: [{Petstore.Gen.GetPetById.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.GetPetById.ResponseValidator, []}]
    ]
  )

  post("/pet/:petId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.UpdatePetWithForm.RequestValidator, []}],
      handlers: [{Petstore.Gen.UpdatePetWithForm.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.UpdatePetWithForm.ResponseValidator, []}]
    ]
  )

  post("/pet/:petId/uploadImage",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.UploadFile.RequestValidator, []}],
      handlers: [{Petstore.Gen.UploadFile.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.UploadFile.ResponseValidator, []}]
    ]
  )

  get("/store/inventory",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.GetInventory.RequestValidator, []}],
      handlers: [{Petstore.Gen.GetInventory.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.GetInventory.ResponseValidator, []}]
    ]
  )

  post("/store/order",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.PlaceOrder.RequestValidator, []}],
      handlers: [{Petstore.Gen.PlaceOrder.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.PlaceOrder.ResponseValidator, []}]
    ]
  )

  delete("/store/order/:orderId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.DeleteOrder.RequestValidator, []}],
      handlers: [{Petstore.Gen.DeleteOrder.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.DeleteOrder.ResponseValidator, []}]
    ]
  )

  get("/store/order/:orderId",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.GetOrderById.RequestValidator, []}],
      handlers: [{Petstore.Gen.GetOrderById.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.GetOrderById.ResponseValidator, []}]
    ]
  )

  post("/user",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.CreateUser.RequestValidator, []}],
      handlers: [{Petstore.Gen.CreateUser.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.CreateUser.ResponseValidator, []}]
    ]
  )

  post("/user/createWithArray",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.CreateUsersWithArrayInput.RequestValidator, []}],
      handlers: [{Petstore.Gen.CreateUsersWithArrayInput.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.CreateUsersWithArrayInput.ResponseValidator, []}]
    ]
  )

  post("/user/createWithList",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.CreateUsersWithListInput.RequestValidator, []}],
      handlers: [{Petstore.Gen.CreateUsersWithListInput.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.CreateUsersWithListInput.ResponseValidator, []}]
    ]
  )

  get("/user/login",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.LoginUser.RequestValidator, []}],
      handlers: [{Petstore.Gen.LoginUser.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.LoginUser.ResponseValidator, []}]
    ]
  )

  get("/user/logout",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.LogoutUser.RequestValidator, []}],
      handlers: [{Petstore.Gen.LogoutUser.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.LogoutUser.ResponseValidator, []}]
    ]
  )

  delete("/user/:username",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.DeleteUser.RequestValidator, []}],
      handlers: [{Petstore.Gen.DeleteUser.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.DeleteUser.ResponseValidator, []}]
    ]
  )

  get("/user/:username",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.GetUserByName.RequestValidator, []}],
      handlers: [{Petstore.Gen.GetUserByName.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.GetUserByName.ResponseValidator, []}]
    ]
  )

  put("/user/:username",
    to: RoutePlug,
    init_opts: [
      preprocessors: [{Petstore.Gen.UpdateUser.RequestValidator, []}],
      handlers: [{Petstore.Gen.UpdateUser.FakeHandler, []}],
      postprocessors: [{Petstore.Gen.UpdateUser.ResponseValidator, []}]
    ]
  )

  match(_, to: MathAllPlug, init_opts: [])
end
