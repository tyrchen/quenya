defmodule QuenyaBuilder.ApiRouter do
  @moduledoc """
  Generate Plug router based on OAPIv3 spec
  """
  require DynamicModule

  alias QuenyaBuilder.{
    RequestValidator,
    ResponseValidator,
    ResponseGenerator,
    UnitTestGenerator,
    Util
  }

  alias QuenyaBuilder.Object

  def gen(doc, base_path, app, opts \\ []) do
    mod_name = Util.gen_api_router_name(app)

    preamble = gen_preamble()

    contents =
      Enum.map(doc, fn {uri, ops} ->
        gen_uri(uri, base_path, ops, app, opts)
      end)
      |> List.flatten()

    suffix = [
      quote do
        match(_, to: MathAllPlug, init_opts: [])
      end
    ]

    DynamicModule.gen(mod_name, preamble, Util.gen_router_preamble() ++ contents ++ suffix, opts)
  end

  defp gen_preamble do
    quote do
      use Plug.Router
      use Plug.ErrorHandler

      require Logger

      alias Quenya.Plug.{RoutePlug, MathAllPlug}
    end
  end

  defp gen_uri(uri, base_path, ops, app, opts) do
    Enum.map(ops, fn {method, doc} ->
      name =
        doc["operationId"] ||
          raise "Must define operationId for #{uri} with method #{method}. It will be used to generate module name"

      method = DynamicModule.normalize_name(method)

      req = Object.gen_req_object(name, doc["requestBody"])
      params = Object.gen_param_objects(name, doc["parameters"])
      res = Object.gen_res_objects(name, doc["responses"])

      new_opts = Keyword.update!(opts, :path, &Path.join(&1, name))
      RequestValidator.gen(req, params, app, name, new_opts)

      if Application.get_env(:quenya, :use_response_validator, true) do
        ResponseValidator.gen(res, app, name, new_opts)
      end

      if Application.get_env(:quenya, :use_fake_handler, true) do
        ResponseGenerator.gen(res, app, name, new_opts)
      end

      ut_opts =
        new_opts
        |> Keyword.put(:type, :test)
        |> Keyword.update!(:path, fn _ -> "test/gen" end)

      if Application.get_env(:quenya, :gen_tests, true) do
        UnitTestGenerator.gen(method, Path.join(base_path, uri), req, params, res, app, name, ut_opts)
      end

      init_opts = gen_route_plug_opts(app, name)

      uri = Util.normalize_uri(uri)

      quote do
        unquote(method)(unquote(uri), to: RoutePlug, init_opts: unquote(init_opts))
      end
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
