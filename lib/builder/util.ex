defmodule Quenya.Builder.Utils do
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

  def normalize_name(nil), do: nil
  def normalize_name(name) when is_atom(name), do: name
  def normalize_name(name), do: String.to_atom(name)

  def get_opts(meta, allowed) do
    meta
    |> Map.take(Map.keys(allowed))
    |> Enum.reduce([], fn {k, v}, acc ->
      new_key = Map.get(allowed, k)
      [{new_key, v} | acc]
    end)
  end

  def not_implemented(item) do
    get_in(item, ["meta", "resolver"]) == false
  end

  def process_meta(p) do
    p
    |> Map.get("meta", %{})
    |> Enum.reduce(%{doc: Map.get(p, "doc", "")}, fn {k, v}, acc ->
      Map.put(acc, String.to_atom(k), v)
    end)
  end
end
