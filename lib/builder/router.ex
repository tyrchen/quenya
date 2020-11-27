defmodule Quenya.Builder.Router do
  @moduledoc """
  Generate Plug router based on OAPIv3 spec
  """
  require DynamicModule
  alias Quenya.Builder.{Request, Response, Util}
  alias QuenyaUtil.Plug.RoutePlug

  def gen(root, app, opts \\ []) do
    IO.puts("generating router.")
    doc = root["paths"] || raise "No route definition in schema"

    mod_name = Util.gen_router_name(app) |> IO.inspect()

    preamble = gen_preamble()

    contents =
      Enum.map(doc, fn {uri, ops} ->
        gen_uri(uri, ops, app, opts)
      end)
      |> List.flatten()

    DynamicModule.gen(mod_name, preamble, contents, opts)
  end

  defp gen_preamble do
    quote do
      use Plug.Router
      plug(:match)

      plug(Plug.Parsers,
        parsers: [:json],
        pass: ["application/json"],
        json_decoder: Jason
      )

      plug(:dispatch)
    end
  end

  defp gen_uri(uri, ops, app, opts) do
    Enum.map(ops, fn {method, doc} ->
      uri = Util.normalize_uri(uri)

      name =
        doc["operationId"] ||
          raise "Must define operationId for #{uri} with method #{method}. It will be used to generate module name"

      new_opts = Keyword.update!(opts, :path, &Path.join(&1, name))
      Request.gen(doc, app, name, new_opts)
      Response.gen(doc, app, name, new_opts)

      method = Util.normalize_name(method)
      init_opts = Util.gen_route_plug_opts(app, name)

      result =
        quote do
          unquote(method)(unquote(uri), to: RoutePlug, init_opts: unquote(init_opts))
        end

      result
    end)
  end
end
