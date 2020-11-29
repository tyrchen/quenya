defmodule Quenya.FormatValidator do
  @moduledoc """
  Custom format validator for ExJsonSchema
  """
  def validate("uuid", data) do
    case UUID.info(data) do
      {:ok, _} -> true
      _ -> false
    end
  end

  def validate("uri", data) do
    uri = URI.parse(data)
    not is_nil(uri.scheme) and uri.host =~ "."
  end

  def validate("image_uri", data) do
    validate("uri", data)
  end

  def validate(_format, _data) do
    true
  end
end
