defmodule Quenya.Parser.RefTable do
  @moduledoc """
  Process the references
  """
  alias Quenya.Parser.Validator

  @ref_table :ref_table

  @doc """
  Init ref table with the main content
  """
  def init(content) do
    if :ets.whereis(@ref_table) == :undefined do
      :ets.new(@ref_table, [:named_table, :set, :protected])
    end

    load_content("#", content)
  end

  def get(path) do
    case String.split(path, "#") do
      # reference whole file
      [filename] ->
        load_file(filename)

      # reference local components
      ["", path] ->
        get_local("#", path)

      # reference remote file with a path
      [filename, path] ->
        load_file(filename)
        get_local(filename, path)
    end
  end

  defp get_local(key, path) do
    [_, l1, l2, l3] = String.split(path, "/")

    case :ets.lookup(@ref_table, key) do
      [{^key, data}] -> data[l1][l2][l3]
      _ -> nil
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
