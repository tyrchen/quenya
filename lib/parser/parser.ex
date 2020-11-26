defmodule Quenya.Parser do
  @moduledoc """
  OpenAPI schema parser
  """
  alias Quenya.Parser.{Validator, RemoteRef}

  @spec parse(binary) :: {:error, :parse | :read} | {:ok, map()}
  def parse(filename) do
    case Validator.validate(filename) do
      {:ok, content} -> do_parse(content)
      {:error, _} -> {:error, :read}
    end
  end

  @spec to_json(String.t()) :: binary
  def to_json(filename), do: Jason.encode!(parse(filename))

  defp do_parse(content) do
    case YamlElixir.read_all_from_string(content) do
      {:ok, [data]} -> do_extend_refs(data)
      {:error, _} -> {:error, :parse}
    end
  end

  defp do_extend_refs(data) do
    data = RemoteRef.update(data)

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
        result = do_reduce_value(data, v, recursive)
        Map.put(acc, k, result)
      end)

    Map.put(data, type, updated)
  end

  defp do_extend_paths(components, paths) do
    Enum.reduce(paths, %{}, fn {k, v}, acc ->
      result = do_reduce_value(components, v, false)
      Map.put(acc, k, result)
    end)
  end

  defp do_extend_ref(data, path, recursive) do
    ["#", _l1, l2, l3] = String.split(path, "/")
    v = data[l2][l3]

    case recursive do
      true -> do_reduce_value(data, v, recursive)
      _ -> v
    end
  end

  defp do_reduce_value(data, val, recursive) do
    Enum.reduce(val, %{}, fn {k, v}, acc ->
      result =
        case v do
          %{"$ref" => path} -> do_extend_ref(data, path, recursive)
          v when is_map(v) -> do_reduce_value(data, v, recursive)
          v -> v
        end

      Map.put(acc, k, result)
    end)
  end
end
