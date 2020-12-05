defmodule QuenyaBuilder.Security do
  @moduledoc """
  Security related functions
  """
  alias QuenyaBuilder.Object.SecurityScheme

  def ensure(security) when length(security) > 1 do
    raise "Though OpenAPI allows to choose one of the security schemes, Quenya only allows one security being used. You could have one security define in OpenAPI object, and one in operation object if you'd want to override top level security definition. This will make the generated security processing code more performant."
  end

  def ensure(security), do: security

  # shall return {scheme_name, opts}
  def normalize(security) do
    (security |> List.first() || %{}) |> Enum.into([]) |> List.first() || {nil, nil}
  end

  def get_scheme(_schemes, nil, _opts), do: nil
  def get_scheme(schemes, name, opts) do
    case Map.get(schemes, name) do
      nil -> raise "Security scheme #{name} is not supported in #{inspect(schemes)}"
      v -> {v, opts}
    end
  end

  def get_plug(nil), do: nil
  def get_plug({%SecurityScheme{type: "apiKey"}, _opts}), do: Quenya.Plug.ApiKeyPlug

  def get_plug({%SecurityScheme{type: "http", scheme: "bearer", bearerFormat: "JWT"}, _opts}),
    do: Quenya.Plug.JwtPlug

  def get_plug(scheme), do: raise("Unsupported security scheme: #{inspect scheme}")
end
