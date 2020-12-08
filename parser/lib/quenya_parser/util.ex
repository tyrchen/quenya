defmodule QuenyaParser.Util do
  @moduledoc """
  Utility functions
  """
  require Logger

  @spec update_map(map() | String.t(), any, boolean(), fun()) ::
          map() | {:error, String.t()}
  @doc """
  Update the map recursively for $ref
  """
  def update_map(context, %{"$ref" => path}, recursive, process_ref_fn) do
    case process_ref_fn.(context, path, recursive) do
      {:error, msg} ->
        Logger.warn("Failed to process #{path}. Error: #{msg}")
        {:error, msg}

      v ->
        v
    end
  end

  def update_map(context, val, recursive, process_ref_fn) when is_map(val) do
    Enum.reduce_while(val, %{}, fn {k, v}, acc ->
      result =
        case v do
          %{"$ref" => _path} ->
            update_map(context, v, recursive, process_ref_fn)

          v when is_list(v) ->
            Enum.map(v, fn item -> update_map(context, item, recursive, process_ref_fn) end)

          v when is_map(v) ->
            update_map(context, v, recursive, process_ref_fn)

          v ->
            v
        end

      case result do
        {:error, msg} -> {:halt, {:error, msg}}
        _ -> {:cont, Map.put(acc, k, result)}
      end
    end)
  end

  def update_map(_context, val, _recursive, _process_ref_fn), do: val
end
