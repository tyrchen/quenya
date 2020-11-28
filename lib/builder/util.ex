defmodule Quenya.Builder.Util do
  @moduledoc """
  General utility functions for code generator
  """

  alias ExJsonSchema.Schema

  @allowed_param_position ["query", "path", "header", "cookie"]

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

  def ensure_position(position) do
    case position in @allowed_param_position do
      true -> position
      _ -> raise "Invalid position #{position}, expected: #{inspect(@allowed_param_position)}."
    end
  end

  def get_response_schemas(resp, position) do
    Enum.reduce(resp, %{}, fn {code, body}, acc1 ->
      result1 =
        Enum.reduce(body[position] || %{}, %{}, fn {k, v}, acc2 ->
          result2 = Schema.resolve(Map.delete(v["schema"], "example"))
          Map.put(acc2, k, schema: result2, required: v["required"] || false)
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
