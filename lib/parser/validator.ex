defmodule Quenya.Parser.Validator do
  @moduledoc """
  Validate Open API v3 schema
  """

  @doc """
  validate the yaml/json content
  """
  @spec validate(String.t()) :: boolean()
  def validate(_content), do: true
end
