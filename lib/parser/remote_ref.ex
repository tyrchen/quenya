defmodule Quenya.Parser.RemoteRef do
  @moduledoc """
  Update remote ref
  """
  require Logger
  alias Quenya.Parser.{Validator, Util}

  @ref_table :ref_table

  @spec update(map()) :: map()
  @doc """
  Iterate the map, update:
  1. inline update for file ref without path.
  2. merge the remote file to current file for file ref with path. Update path as a local path.
  """
  def update(data) do
    if :ets.whereis(@ref_table) == :undefined do
      :ets.new(@ref_table, [:named_table, :set, :protected])
    end

    result =
      Enum.reduce(data, %{}, fn {k, v}, acc ->
        result =
          Util.update_map(
            nil,
            v,
            false,
            fn comp, path, recursive -> do_extend_ref(comp, path, recursive) end
          )

        Map.put(acc, k, result)
      end)

    merged =
      Enum.reduce(:ets.tab2list(@ref_table), result, fn {_k, v}, acc ->
        DeepMerge.deep_merge(acc, v)
      end)

    :ets.delete(@ref_table)

    merged
  end

  defp do_extend_ref(_data, path, _recursive) do
    case String.split(path, "#") do
      # reference whole file
      [filename] ->
        load_file(filename)

      # reference local components
      ["", _p] ->
        %{"$ref" => path}

      # reference remote file with a path
      [filename, p] ->
        load_file(filename)
        %{"$ref" => "##{p}"}

      _ ->
        Logger.warn("Unknown path: #{path}")
        %{"$ref" => path}
    end
  end

  defp load_file(filename) do
    case :ets.lookup(@ref_table, filename) do
      [{^filename, data}] ->
        data

      _ ->
        case Validator.validate(filename) do
          {:ok, content} -> load_content(filename, content)
          {:error, _} -> {:error, :invalid_ref_file}
        end
    end
  end

  defp load_content(key, content) do
    case YamlElixir.read_all_from_string(content) do
      {:ok, [data]} ->
        :ets.insert(@ref_table, {key, data})
        data

      {:error, _} ->
        {:error, :invalid_ref_content}
    end
  end
end
