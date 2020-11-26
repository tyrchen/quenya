defmodule Quenya.Oas do
  @moduledoc """
  Documentation for `Oas`.
  """

  use Rustler, otp_app: :quenya, crate: :oas
  def to_json(_path), do: err()

  defp err, do: :erlang.nif_error(:nif_not_loaded)
end
