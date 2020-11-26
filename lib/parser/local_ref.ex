defmodule Quenya.Parser.LocalRef do
  @moduledoc """
  Process local reference
  """
  alias Quenya.Parser.Util

  @doc """
  Iterate the map and replace all $ref to the actual data
  """
  @spec update(map) :: map
  def update(data) do
    components =
      data
      |> Map.get("components")
      |> do_extend_components("schemas")
      |> do_extend_components("parameters")
      |> do_extend_components("responses")

    paths = do_extend_paths(components, Map.get(data, "paths"))

    data
    |> Map.put("components", components)
    |> Map.put("paths", paths)
  end

  defp do_extend_components(data, type) do
    recursive =
      case type do
        "schemas" -> true
        _ -> false
      end

    updated =
      Enum.reduce(data[type], %{}, fn {k, v}, acc ->
        result =
          Util.update_map(
            data,
            v,
            recursive,
            fn comp, path, recursive -> do_extend_ref(comp, path, recursive) end
          )

        Map.put(acc, k, result)
      end)

    Map.put(data, type, updated)
  end

  defp do_extend_paths(components, paths) do
    Enum.reduce(paths, %{}, fn {k, v}, acc ->
      result =
        Util.update_map(
          components,
          v,
          false,
          fn comp, path, recursive -> do_extend_ref(comp, path, recursive) end
        )

      Map.put(acc, k, result)
    end)
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
          fn comp, path, recursive -> do_extend_ref(comp, path, recursive) end
        )

      _ ->
        v
    end
  end
end
