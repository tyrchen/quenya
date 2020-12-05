defmodule QuenyaBuilder.Config do
  @moduledoc """
  Load and save quenya configuration
  """
  @template """
  ---<%= for {name, preprocessors, handlers, postprocessors} <- data do %>
  <%= name %>:
    preprocessors:<%= for {mod, opts} <- preprocessors do %>
      - <%= mod %>: <%= opts %><% end %>
    handlers:<%= for {mod, opts} <- handlers do %>
      - <%= mod %>: <%= opts %><% end %>
    postprocessors:<%= for {mod, opts} <- postprocessors do %>
      - <%= mod %>: <%= opts %><% end %>
  <% end %>
  """

  @doc """
  Load configuration from priv/api_config.yml
  """
  def load(filename) do
    filename
    |> YamlElixir.read_from_file!()
    |> Enum.reduce(%{}, fn {name, ops}, acc ->
      preprocessors = ops["preprocessors"] || []
      handlers = ops["handlers"] || []
      postprocessors = ops["postprocessors"] || []

      ops = [
        preprocessors: normalize_opts(preprocessors),
        handlers: normalize_opts(handlers),
        postprocessors: normalize_opts(postprocessors)
      ]

      Map.put(acc, name, ops)
    end)
  end

  @doc """
  Save configuration to priv_api_config.yml if the file not exists
  """
  def save(filename, data) do
    data = Enum.map(data, fn {name, pre, h, post} -> {name, denormalize_opts(pre), denormalize_opts(h), denormalize_opts(post)} end)
    content = EEx.eval_string(@template, data: data)
    File.write!(filename, content)
  end

  defp normalize_opts(data) do
    Enum.map(data, fn item ->
      Enum.map(item, fn {mod, opts} ->
        opts = Enum.map(opts, fn {k, v} -> {String.to_atom(k), v} end)
        {mod, opts}
      end)
    end)
    |> List.flatten()

  end

  defp denormalize_opts(data) do
    Enum.map(data, fn {mod, opts} ->
      mod = mod |> Atom.to_string() |> String.replace("Elixir.", "")
      opts = Enum.into(opts, %{})
      {mod, Jason.encode!(opts)}
    end)
  end
end
