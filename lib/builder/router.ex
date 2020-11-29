defmodule Quenya.Builder.Router do
  @moduledoc """
  Generate Plug router based on OAPIv3 spec
  """
  require DynamicModule
  alias Quenya.Builder.{ApiRouter, Util}

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
      alias QuenyaUtil.Plug.{SwaggerPlug, MathAllPlug}

      alias QuenyaUtil.Plug.{SwaggerPlug, MathAllPlug}

      plug(Plug.Logger, log: :info)

      plug(Plug.Static, at: "/public", from: {:quenya_util, "priv/swagger"})
    end
  end

  defp gen_contents(servers, app) do
    uri =
      Util.get_localhost_uri(servers) || raise "Must define localhost under servers in OAS3 spec."

    path = uri.path
    api_router_mod = Module.concat("Elixir", Util.gen_api_router_name(app))

    Util.gen_router_preamble() ++
      [
        quote do
          get("/swagger/main.json", to: SwaggerPlug, init_opts: [app: unquote(app)])
          get("/swagger", to: SwaggerPlug, init_opts: [spec: "/swagger/main.json"])

          forward(unquote(path), to: unquote(api_router_mod), init_opts: [])

          match(_, to: MathAllPlug, init_opts: [])
        end
      ]
  end
end
