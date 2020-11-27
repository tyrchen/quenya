defmodule Quenya.Builder.Util do
  @moduledoc """
  General utility functions for code generator
  """

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

  def gen_router_name(app) do
    gen_module_name(app, "Gen", "Router")
  end

  def ensure_position(position) do
    case position in @allowed_param_position do
      true -> position
      _ -> raise "Invalid position #{position}, expected: #{inspect(@allowed_param_position)}."
    end
  end

  def gen_route_plug_opts(app, name) do
    req_validate_mod = Module.concat("Elixir", gen_request_validator_name(app, name))
    res_validate_mod = Module.concat("Elixir", gen_response_validator_name(app, name))
    [preprocessors: [req_validate_mod], post_processors: [res_validate_mod], handlers: []]
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
