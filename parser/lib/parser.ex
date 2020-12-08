defmodule QuenyaParser do
  @moduledoc """
  OpenAPI schema parser
  """
  alias QuenyaParser.{Validator, RemoteRef, LocalRef}

  @spec parse(binary) :: {:error, String.t()} | {:ok, map()}
  def parse(filename) do
    case Validator.validate(filename) do
      {:ok, content} -> do_parse(Path.dirname(filename), content)
      {:error, _} -> {:error, "failed to read or validate file #{filename}"}
    end
  end

  @spec to_json(String.t()) :: binary | {:error, String.t()}
  def to_json(filename) do
    case parse(filename) do
      {:ok, data} -> Jason.encode!(data)
      e -> e
    end
  end

  defp do_parse(dir, content) do
    case YamlElixir.read_from_string(content) do
      {:ok, data} -> do_extend_refs(dir, data)
      {:error, _} -> {:error, "failed to parse yaml content"}
    end
  end

  defp do_extend_refs(dir, data) do
    with {:ok, r1} <- RemoteRef.update(data, dir),
         {:ok, r2} <- LocalRef.update(r1) do
      {:ok, r2}
    else
      e -> e
    end
  end
end
