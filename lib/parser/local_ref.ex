defmodule Quenya.Parser.LocalRef do
  @moduledoc """
  Process local reference
  """
  alias Quenya.Parser.Util

  @doc """
  Iterate the map and replace all $ref to the actual data
  """
  @spec update(map()) :: {:ok, map()} | {:error, String.t()}
  def update(data) do
    with {:ok, comp} <- Map.fetch(data, "components"),
         {:ok, comp1} <- do_extend_components(comp, "schemas"),
         {:ok, comp2} <- do_extend_components(comp1, "parameters"),
         {:ok, comp3} <- do_extend_components(comp2, "requestBodies"),
         {:ok, comp4} <- do_extend_components(comp3, "responses"),
         {:ok, paths} <- do_extend_paths(comp4, Map.get(data, "paths")) do
      {:ok, %{data | "components" => comp4, "paths" => paths}}
    else
      e -> e
    end
  end

  defp do_extend_components(data, type) do
    recursive =
      case type do
        "schemas" -> true
        _ -> false
      end

    updated =
      Enum.reduce_while(data[type] || %{}, %{}, fn {k, v}, acc ->
        result =
          Util.update_map(
            data,
            v,
            recursive,
            fn context, path, recursive -> do_extend_ref(context, path, recursive) end
          )

        case result do
          {:error, msg} -> {:halt, {:error, msg}}
          _v -> {:cont, Map.put(acc, k, result)}
        end
      end)

    case updated do
      {:error, msg} -> {:error, msg}
      _ -> {:ok, Map.put(data, type, updated)}
    end
  end

  defp do_extend_paths(components, paths) do
    updated =
      Enum.reduce_while(paths, %{}, fn {k, v}, acc ->
        result =
          Util.update_map(
            components,
            v,
            false,
            fn context, path, recursive -> do_extend_ref(context, path, recursive) end
          )

        case result do
          {:error, msg} -> {:halt, {:error, msg}}
          _v -> {:cont, Map.put(acc, k, result)}
        end
      end)

    case updated do
      {:error, msg} -> {:error, msg}
      _ -> {:ok, updated}
    end
  end

  defp do_extend_ref(data, path, recursive) do
    ["#", _l1, l2, l3] = String.split(path, "/")
    v = data[l2][l3]

    case recursive do
      true ->
        Util.update_map(
          data,
          v,
          recursive,
          fn context, path, recursive -> do_extend_ref(context, path, recursive) end
        )

      _ ->
        v
    end
  rescue
    _ -> {:error, "failed to extend ref for #{path}"}
  end
end
