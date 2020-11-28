defmodule Quenya.Builder.Router do
  @moduledoc """
  Generate Plug router based on OAPIv3 spec
  """
  require DynamicModule
  alias Quenya.Builder.{RequestValidator, ResponseValidator, ResponseGenerator, Util}
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
      RequestValidator.gen(doc, app, name, new_opts)
      ResponseValidator.gen(doc, app, name, new_opts)

      if Application.fetch_env!(:quenya, :use_response_validator) do
        ResponseGenerator.gen(doc, app, name, new_opts)
      end

      method = Util.normalize_name(method)
      init_opts = gen_route_plug_opts(app, name)

      result =
        quote do
          unquote(method)(unquote(uri), to: RoutePlug, init_opts: unquote(init_opts))
        end

      result
    end)
  end

  defp gen_route_plug_opts(app, name) do
    config = Application.get_all_env(:quenya)
    {preprocessors, handlers, postprocessors} = Util.get_api_config(name)
    req_validator_mod = Module.concat("Elixir", Util.gen_request_validator_name(app, name))
    res_validator_mod = Module.concat("Elixir", Util.gen_response_validator_name(app, name))
    fake_handler_mod = Module.concat("Elixir", Util.gen_fake_handler_name(app, name))

    preprocessors = [req_validator_mod | preprocessors]

    postprocessors =
      case config[:use_response_validator] do
        true -> [res_validator_mod | postprocessors]
        _ -> postprocessors
      end

    handlers =
      case config[:use_fake_handler] do
        true -> [fake_handler_mod | handlers]
        _ -> handlers
      end

    [preprocessors: preprocessors, postprocessors: postprocessors, handlers: handlers]
  end
end
