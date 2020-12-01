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

  def gen_router_name(app) do
    gen_module_name(app, "Gen", "Router")
  end

  def gen_api_router_name(app) do
    gen_module_name(app, "Gen", "ApiRouter")
  end

  def get_localhost_uri(servers) do
    Enum.reduce_while(servers, nil, fn %{"url" => url}, _acc ->
      case URI.parse(url) do
        %URI{host: "localhost"} = uri -> {:halt, uri}
        _ -> {:cont, nil}
      end
    end)
  end

  def get_response_schemas(data, position) when position in ["headers", "content"] do
    Enum.reduce(data, %{}, fn {code, item}, acc1 ->
      item =
        case position do
          "headers" -> item.headers
          "content" -> item.content
        end

      result1 =
        Enum.reduce(item, %{}, fn {k, v}, acc2 ->
          Map.put(acc2, k, schema: v.schema, required: Map.get(v, :required) || false)
        end)

      case Enum.empty?(result1) do
        true -> acc1
        _ -> Map.put(acc1, code, result1)
      end
    end)
  end

  def choose_best_code_schema(schemas) do
    case schemas["200"] do
      nil ->
        status =
          schemas
          |> Map.keys()
          |> Enum.reduce_while(nil, fn item, _acc ->
            case item do
              "2" <> _ -> {:halt, item}
              _ -> {:cont, item}
            end
          end) || "200"

        code =
          case status do
            "default" -> 200
            _ -> String.to_integer(status)
          end

        {code, schemas[status]}

      v ->
        {200, v}
    end
  end

  def gen_router_preamble do
    [
      quote do
        plug(:match)

        plug(Plug.Parsers,
          parsers: [:json],
          pass: ["application/json"],
          json_decoder: Jason
        )

        plug(:dispatch)

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

  def get_api_config(name) do
    config = Application.get_all_env(:quenya)[:apis][name] || %{}

    {config[:preprocessors] || [], config[:handlers] || [], config[:postprocessors] || []}
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

  def normalize_name(nil), do: nil
  def normalize_name(name) when is_atom(name), do: name
  def normalize_name(name), do: String.to_atom(name)
end
