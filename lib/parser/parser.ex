defmodule Quenya.Parser do
  @moduledoc """
  OpenAPI schema parser
  """
  alias Quenya.Parser.{Validator, RemoteRef, LocalRef}

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

    data
    |> RemoteRef.update()
    |> LocalRef.update()
  end
end
