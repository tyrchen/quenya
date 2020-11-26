defmodule Quenya.Parser.RemoteRef do
  @moduledoc """
  Update remote ref
  """
  require Logger
  alias Quenya.Parser.{Validator, Util}

  @ref_table :ref_table

  @spec update(map(), String.t()) :: {:ok, map()} | {:error, String.t()}
  @doc """
  Iterate the map, update:
  1. inline update for file ref without path.
  2. merge the remote file to current file for file ref with path. Update path as a local path.
  """
  def update(data, dir) do
    if :ets.whereis(@ref_table) == :undefined do
      :ets.new(@ref_table, [:named_table, :set, :protected])
    end

    result =
      Enum.reduce_while(data, %{}, fn {k, v}, acc ->
        result =
          Util.update_map(
            dir,
            v,
            false,
            fn context, path, recursive -> do_extend_ref(context, path, recursive) end
          )

        case result do
          {:error, msg} -> {:halt, {:error, msg}}
          _v -> {:cont, Map.put(acc, k, result)}
        end
      end)

    case result do
      {:error, msg} ->
        :ets.delete(@ref_table)
        {:error, msg}

      _v ->
        merged =
          Enum.reduce(:ets.tab2list(@ref_table), result, fn {_k, v}, acc ->
            DeepMerge.deep_merge(acc, v)
          end)

        :ets.delete(@ref_table)

        {:ok, merged}
    end
  end

  defp do_extend_ref(dir, path, _recursive) do
    case String.split(path, "#") do
      # reference whole file
      [filename] ->
        load_file(Path.join(dir, filename), false)

      # reference local components
      ["", _p] ->
        %{"$ref" => path}

      # reference remote file with a path
      [filename, p] ->
        case load_file(Path.join(dir, filename), true) do
          {:error, msg} -> {:error, msg}
          _ -> %{"$ref" => "##{p}"}
        end

      _ ->
        msg = "Unknown path: #{path}"
        Logger.warn(msg)
        {:error, msg}
    end
  end

  defp load_file(filename, store?) do
    case :ets.lookup(@ref_table, filename) do
      [{^filename, data}] ->
        data

      _ ->
        case Validator.validate(filename) do
          {:ok, content} -> load_content(filename, content, store?)
          {:error, _} -> {:error, :invalid_ref_file}
        end
    end
  end

  defp load_content(key, content, store?) do
    case YamlElixir.read_from_string(content) do
      {:ok, data} ->
        if store? do
          :ets.insert(@ref_table, {key, data})
        end

        data

      {:error, _} ->
        {:error, :invalid_ref_content}
    end
  end
end
