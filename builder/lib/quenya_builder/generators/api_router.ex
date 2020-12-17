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

  def gen(root, base_path, app, opts \\ []) do
    mod_name = Util.gen_api_router_name(app)

    preamble = gen_preamble()

    config_file = "priv/api_config_#{Mix.env()}.yml"

    config =
      case File.exists?(config_file) do
        true -> Config.load(config_file)
        _ -> %{}
      end

    sec_schemes = root.security_schemes
    security = Security.ensure(root.security || [])

    data =
      root.paths
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
    Enum.map(ops, fn {method, op} ->
      [
        uri: uri,
        base_path: base_path,
        app: app,
        config: config,
        sec_schemes: sec_schemes,
        security: security
      ] = op_opts

      {scheme_name, scheme_opts} =
        Security.ensure(op.security || security) |> Security.normalize()

      security_data = Security.get_scheme(sec_schemes, scheme_name, scheme_opts)

      name = op.operation_id

      method = DynamicModule.normalize_name(method)

      req = op.request_body
      params = op.parameters
      res = op.responses

      new_mod_opts = Keyword.update!(mod_opts, :path, &Path.join(&1, name))
      RequestValidator.gen(req, params, app, name, new_mod_opts)

      preprocessors = get_preprocessors(app, name, security_data)
      handlers = []
      postprocessors = []

      postprocessors =
        case Application.get_env(:quenya, :use_response_validator, true) do
          true ->
            ResponseValidator.gen(res, app, name, new_mod_opts)
            get_post_processors(app, name)

          _ ->
            postprocessors
        end

      handlers =
        case Application.get_env(:quenya, :use_fake_handler, true) do
          true ->
            FakeHandler.gen(res, app, name, new_mod_opts)
            get_handlers(app, name)

          _ ->
            handlers
        end

      ut_mod_opts =
        new_mod_opts
        |> Keyword.put(:type, :test)
        |> Keyword.update!(:path, fn _ -> "test/gen" end)

      if Application.get_env(:quenya, :gen_tests, true) do
        data = [req: req, params: params, res: res, security_data: security_data]
        UnitTest.gen(method, Path.join(base_path, uri), data, app, name, ut_mod_opts)
      end

      init_opts = gen_route_plug_opts(preprocessors, handlers, postprocessors, config[name])
      uri = Util.normalize_uri(uri)
      {name, method, uri, init_opts}
    end)
  end

  defp get_preprocessors(app, name, security_data) do
    req_validator_mod = Module.concat("Elixir", Util.gen_request_validator_name(app, name))

    case Security.get_plug(security_data) do
      nil -> [{req_validator_mod, []}]
      security_plug -> [{security_plug, []}, {req_validator_mod, []}]
    end
  end

  defp get_post_processors(app, name) do
    res_validator_mod = Module.concat("Elixir", Util.gen_response_validator_name(app, name))
    [{res_validator_mod, []}]
  end

  defp get_handlers(app, name) do
    fake_handler_mod = Module.concat("Elixir", Util.gen_fake_handler_name(app, name))
    [{fake_handler_mod, []}]
  end

  defp gen_route_plug_opts(preprocessors, handlers, postprocessors, nil) do
    [
      preprocessors: preprocessors,
      handlers: handlers,
      postprocessors: postprocessors
    ]
  end

  defp gen_route_plug_opts(preprocessors, handlers, postprocessors, data) do
    data_from_spec = gen_route_plug_opts(preprocessors, handlers, postprocessors, nil)

    # we want to preserve user modified config, while still pickup the changes from
    # the OpenAPI spec. say, user added new security config in an existing operation,
    # we need to make sure it is properly picked up.
    DeepMerge.deep_merge(data_from_spec, data, fn
      _, original, override when is_list(original) and is_list(override) ->
        case Keyword.keyword?(original) do
          true -> DeepMerge.continue_deep_merge()
          _ -> Enum.dedup_by(original ++ override, fn {x, _} -> x end)
        end

      _, _original, _override ->
        DeepMerge.continue_deep_merge()
    end)
  end

  defp save_config(config_file, data) do
    config_data =
      Enum.map(data, fn {name, _method, _uri, opts} ->
        {name, opts[:preprocessors], opts[:handlers], opts[:postprocessors]}
      end)

    Config.save(config_file, config_data)
  end
end
