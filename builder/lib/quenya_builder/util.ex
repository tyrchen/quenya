defmodule QuenyaBuilder.Util do
  @moduledoc """
  General utility functions for code generator
  """

  def gen_module_name(app, prefix, name, postfix \\ "") do
    app_name = gen_app_name(app)
    name = name |> Recase.to_pascal()

    case postfix do
      "" -> "#{app_name}.#{prefix}.#{name}"
      _ -> "#{app_name}.#{prefix}.#{name}.#{postfix}"
    end
  end

  def gen_app_name(app), do: app |> Atom.to_string() |> Recase.to_pascal()

  def gen_request_validator_name(app, name) do
    gen_module_name(app, "Gen", name, "RequestValidator")
  end

  def gen_response_validator_name(app, name) do
    gen_module_name(app, "Gen", name, "ResponseValidator")
  end

  def gen_plug_name(app, name) do
    gen_module_name(app, "Gen", name, "Plug")
  end

  def gen_fake_handler_name(app, name) do
    gen_module_name(app, "Gen", name, "FakeHandler")
  end

  def gen_test_name(app, name) do
    gen_module_name(:"#{app}_test", "Gen", name)
  end

  def gen_test_hook_name(app, name) do
    gen_module_name(:"#{app}_test", "Hooks", name)
  end

  def gen_router_name(app) do
    gen_module_name(app, "Gen", "Router")
  end

  def gen_api_router_name(app) do
    gen_module_name(app, "Gen", "ApiRouter")
  end

  def get_localhost_uri(servers) do
    Enum.reduce_while(servers, nil, fn %{url: url}, _acc ->
      case URI.parse(url) do
        %URI{host: "localhost"} = uri -> {:halt, uri}
        _ -> {:cont, nil}
      end
    end)
  end

  def shrink_response_data(data, position) when position in ["headers", "content"] do
    Enum.reduce(data, %{}, fn {code, item}, acc1 ->
      item =
        case position do
          "headers" -> item.headers
          "content" -> item.content
        end

      result1 =
        Enum.reduce(item, %{}, fn {k, v}, acc2 ->
          Map.put(acc2, k, {k, v.schema, Map.get(v, :required) || false})
        end)

      Map.put(acc1, code, result1)
    end)
  end

  def gen_router_preamble do
    [
      quote do
        plug :match

        plug Plug.Parsers,
          parsers: [:urlencoded, :multipart, :json],
          pass: ["application/json"],
          json_decoder: Jason

        plug :dispatch

        def handle_errors(conn, %{kind: _kind, reason: %{message: msg}, stack: _stack}) do
          Plug.Conn.send_resp(conn, conn.status, msg)
        end

        def handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
          Logger.warn(
            "Internal error:\n kind: #{inspect(kind)}\n reason: #{inspect(reason)}\n stack: #{
              inspect(stack)
            }"
          )

          Plug.Conn.send_resp(conn, conn.status, "Internal server error")
        end
      end
    ]
  end

  def normalize_uri(uri) do
    # "/todo/{todoId}"
    uri
    |> String.split("/")
    |> Enum.map(fn part ->
      case part do
        "{" <> param -> ":#{String.trim_trailing(param, "}")}"
        _ -> part
      end
    end)
    |> Enum.join("/")
  end
end
