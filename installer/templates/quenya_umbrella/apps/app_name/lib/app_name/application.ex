defmodule <%= @app_module %>.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Application.get_env(:<%= @app_name %>, :http, [])[:port] || 4000
    children = [
      {Plug.Cowboy, scheme: :http, plug: <%= @app_module %>.Gen.Router, options: [port: port]}
    ]


    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: <%= @app_module %>.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
