defmodule QuenyaBuilder.Generator.Router do
  @moduledoc """
  Generate Plug router based on OAPIv3 spec
  """
  require DynamicModule
  alias QuenyaBuilder.{Generator.ApiRouter, Util}

  def gen(root, app, opts \\ []) do
    if root["paths"] == nil do
      raise "No route definition in schema"
    end

    mod_name = Util.gen_router_name(app)

    uri =
      Util.get_localhost_uri(root["servers"]) ||
        raise "Must define localhost under servers in OAS3 spec."

    base_path = uri.path || "/"

    preamble = gen_preamble()
    contents = gen_contents(base_path, app)

    ApiRouter.gen(root, base_path, app, opts)

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

  defp gen_contents(path, app) do
    api_router_mod = Module.concat("Elixir", Util.gen_api_router_name(app))

    routes = [
      quote do
        get("/swagger/main.json", to: SwaggerPlug, init_opts: [app: unquote(app)])
        get("/swagger", to: SwaggerPlug, init_opts: [spec: "/swagger/main.json"])

        forward(unquote(path), to: unquote(api_router_mod), init_opts: [])
      end
    ]

    match_all =
      case path do
        "/" ->
          [
            quote do
            end
          ]

        _ ->
          [
            quote do
              match(_, to: Quenya.Plug.MathAllPlug, init_opts: [])
            end
          ]
      end

    Util.gen_router_preamble() ++ routes ++ match_all
  end
end
