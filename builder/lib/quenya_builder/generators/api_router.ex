defmodule QuenyaBuilder.Generator.ApiRouter do
  @moduledoc """
  Generate Plug router based on OAPIv3 spec
  """
  require DynamicModule

  alias QuenyaBuilder.Generator.{
    Config,
    RequestValidator,
    ResponseValidator,
    FakeHandler,
    UnitTest
  }

  alias QuenyaBuilder.{Security, Util}

  alias QuenyaBuilder.Object

  def gen(root, base_path, app, opts \\ []) do
    mod_name = Util.gen_api_router_name(app)

    preamble = gen_preamble()

    config_file = "priv/api_config.yml"

    config =
      case File.exists?(config_file) do
        true -> Config.load(config_file)
        _ -> %{}
      end

    sec_schemes = Object.gen_security_schemes(root["components"]["securitySchemes"])
    security = Security.ensure(root["security"] || [])

    data =
      root["paths"]
      |> Enum.map(fn {uri, ops} ->
        op_opts = [
          uri: uri,
          base_path: base_path,
          app: app,
          config: config,
          sec_schemes: sec_schemes,
          security: security
        ]

        gen_uri(ops, op_opts, opts)
      end)
      |> List.flatten()

    save_config(config_file, data)

    contents =
      Enum.map(data, fn {_name, method, uri, init_opts} ->
        quote do
          unquote(method)(unquote(uri), to: RoutePlug, init_opts: unquote(init_opts))
        end
      end)

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

  defp gen_uri(ops, op_opts, mod_opts) do
    Enum.map(ops, fn {method, doc} ->
      [
        uri: uri,
        base_path: base_path,
        app: app,
        config: config,
        sec_schemes: sec_schemes,
        security: security
      ] = op_opts

      {scheme_name, scheme_opts} =
        Security.ensure(doc["security"] || security) |> Security.normalize()

      security_data = Security.get_scheme(sec_schemes, scheme_name, scheme_opts)

      name =
        doc["operationId"] ||
          raise "Must define operationId for #{uri} with method #{method}. It will be used to generate module name"

      method = DynamicModule.normalize_name(method)

      req = Object.gen_req_object(name, doc["requestBody"])
      params = Object.gen_param_objects(name, doc["parameters"])
      res = Object.gen_res_objects(name, doc["responses"])

      new_mod_opts = Keyword.update!(mod_opts, :path, &Path.join(&1, name))
      RequestValidator.gen(req, params, app, name, new_mod_opts)

      if Application.get_env(:quenya, :use_response_validator, true) do
        ResponseValidator.gen(res, app, name, new_mod_opts)
      end

      if Application.get_env(:quenya, :use_fake_handler, true) do
        FakeHandler.gen(res, app, name, new_mod_opts)
      end

      ut_mod_opts =
        new_mod_opts
        |> Keyword.put(:type, :test)
        |> Keyword.update!(:path, fn _ -> "test/gen" end)

      if Application.get_env(:quenya, :gen_tests, true) do
        data = [req: req, params: params, res: res, security_data: security_data]
        UnitTest.gen(method, Path.join(base_path, uri), data, app, name, ut_mod_opts)
      end

      init_opts = gen_route_plug_opts(app, name, security_data, config[name])
      uri = Util.normalize_uri(uri)
      {name, method, uri, init_opts}
    end)
  end

  defp gen_route_plug_opts(app, name, security_data, nil) do
    req_validator_mod = Module.concat("Elixir", Util.gen_request_validator_name(app, name))
    res_validator_mod = Module.concat("Elixir", Util.gen_response_validator_name(app, name))
    fake_handler_mod = Module.concat("Elixir", Util.gen_fake_handler_name(app, name))

    preprocessors = case Security.get_plug(security_data) do
      nil -> [{req_validator_mod, []}]
      security_plug -> [{security_plug, []}, {req_validator_mod, []}]
    end

    [
      preprocessors: preprocessors,
      handlers: [{fake_handler_mod, []}],
      postprocessors: [{res_validator_mod, []}]
    ]
  end

  defp gen_route_plug_opts(_app, _name, _security_data, data), do: data

  defp save_config(config_file, data) do
    config_data =
      Enum.map(data, fn {name, _method, _uri, opts} ->
        {name, opts[:preprocessors], opts[:handlers], opts[:postprocessors]}
      end)

    Config.save(config_file, config_data)
  end
end