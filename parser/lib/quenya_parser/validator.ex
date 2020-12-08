defmodule QuenyaParser.Validator do
  @moduledoc """
  Validate Open API v3 schema
  """

  @doc """
  validate the yaml/json file
  """
  @spec validate(String.t()) :: {:ok, String.t()} | {:error, :invalid_file}
  def validate(filename) do
    case File.read(filename) do
      {:ok, content} -> do_validate(content)
      {:error, _} -> {:error, :invalid_file}
    end
  end

  # TODO: validate the content
  defp do_validate(content), do: {:ok, content}
end
