defmodule Quenya.Token do
  @moduledoc """
  JWT token handler
  """

  require Logger

  use Joken.Config

  @default_exp 2 * 7 * 24 * 60 * 60
  @access_token_type 1
  @refresh_token_type 2

  @doc """
  Generate a new access token
  """
  @spec create_access_token(map()) :: {binary(), integer()}
  def create_access_token(context) do
    data = Map.merge(context, %{"type" => @access_token_type})
    {generate_and_sign!(data), @default_exp}
  end

  @doc """
  Generate a new refresh token
  """
  @spec create_refresh_token(map()) :: {binary(), String.t()}
  def create_refresh_token(context) do
    uuid = UUID.uuid4()
    data = Map.merge(context, %{"type" => @refresh_token_type, "uuid" => uuid})
    {generate_and_sign!(data), uuid}
  end

  def is_access_token(%{"type" => @access_token_type}), do: true
  def is_access_token(_claim), do: false

  def is_refresh_token(%{"type" => @refresh_token_type}), do: true
  def is_refresh_token(%{}), do: false

  @impl true
  def token_config do
    default_exp = Application.get_env(:joken, :default_exp, @default_exp)
    iss = Application.get_env(:joken, :iss, "quenya")
    default_claims(default_exp: default_exp, iss: iss)
  end
end
