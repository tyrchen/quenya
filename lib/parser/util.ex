defmodule Quenya.Parser.Util do
  @moduledoc """
  Utility functions
  """

  @doc """
  Update the map recursively for $ref
  """
  def update_map(components, val, recursive, process_ref_fn) when is_map(val) do
    Enum.reduce(val, %{}, fn {k, v}, acc ->
      result =
        case v do
          %{"$ref" => path} -> process_ref_fn.(components, path, recursive)
          v when is_map(v) -> update_map(components, v, recursive, process_ref_fn)
          v -> v
        end

      Map.put(acc, k, result)
    end)
  end

  def update_map(_components, val, _recursive, _process_ref_fn), do: val
end
