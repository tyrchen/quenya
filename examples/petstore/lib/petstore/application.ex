defmodule Petstore.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Petstore.Gen.Router, options: [port: 8080]}
    ]

    opts = [strategy: :one_for_one, name: Petstore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
