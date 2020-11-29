defmodule QuenyaBuilder.Router do
  @moduledoc """
  Generate Plug router based on OAPIv3 spec
  """
  require DynamicModule
  alias QuenyaBuilder.{ApiRouter, Util}

  def gen(root, app, opts \\ []) do
    doc = root["paths"] || raise "No route definition in schema"

    mod_name = Util.gen_router_name(app)

    preamble = gen_preamble()
    contents = gen_contents(root["servers"], app)

    ApiRouter.gen(doc, app, opts)

    DynamicModule.gen(mod_name, preamble, contents, opts)
  end

  defp gen_preamble do
    quote do
      use Plug.Router
      use Plug.ErrorHandler

      require Logger
      alias Quenya.Plug.SwaggerPlug

      plug(Plug.Logger, log: :info)

      plug(Plug.Static, at: "/public", from: {:quenya, "priv/swagger"})
    end
  end

  defp gen_contents(servers, app) do
    uri =
      Util.get_localhost_uri(servers) || raise "Must define localhost under servers in OAS3 spec."

    path = uri.path || "/"
    api_router_mod = Module.concat("Elixir", Util.gen_api_router_name(app))

    routes = [
      quote do
        get("/swagger/main.json", to: SwaggerPlug, init_opts: [app: unquote(app)])
        get("/swagger", to: SwaggerPlug, init_opts: [spec: "/swagger/main.json"])

        forward(unquote(path), to: unquote(api_router_mod), init_opts: [])
      end
    ]

    match_all = case path do
      "/" -> [quote do

      end]
      _ -> [quote do
        match(_, to: Quenya.Plug.MathAllPlug, init_opts: [])
      end]
    end
    Util.gen_router_preamble() ++ routes ++ match_all
  end
end
