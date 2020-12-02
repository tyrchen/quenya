defmodule Quenya.TestHelper do
  @moduledoc """
  Helper functions for property tests
  """

  alias Quenya.ResponseHelper

  def stream_gen_uri(uri, params) do
    template =
      uri
      |> String.replace("{", "<%= ")
      |> String.replace("}", " %>")

    stream_gen(fn ->
      opts =
        params
        |> params_filter_map("path")
        |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)

      uri = EEx.eval_string(template, opts)

      case URI.encode_query(params_filter_map(params, "query")) do
        "" -> uri
        query -> "#{uri}?#{query}"
      end
    end)
  end

  def stream_gen_req_headers(params) do
    stream_gen(fn ->
      params_filter_map(params, "header")
    end)
  end

  def stream_gen_req_body(c) when c == %{}, do: StreamData.constant(nil)

  def stream_gen_req_body(content) do
    stream_gen(fn ->
      type = Enum.random(Map.keys(content))
      data = get_one(JsonDataFaker.generate(content[type].schema))
      {type, data}
    end)
  end

  def stream_gen_res(res) do
    stream_gen(fn ->
      {code, data} = ResponseHelper.choose_best_response(res)

      headers =
        Enum.map(data.headers, fn {k, v} ->
          {k, v.schema}
        end)

      case Enum.empty?(data.content) do
        true ->
          {code, headers, "*/*", %{}}

        _ ->
          type = Enum.random(Map.keys(data.content))
          {code, headers, type, data.content[type].schema}
      end
    end)
  end

  def stream_gen(fun) do
    StreamData.map(StreamData.constant(nil), fn _ -> fun.() end)
  end

  def get_one(stream_data), do: stream_data |> Enum.take(1) |> List.first()

  # private functions

  defp params_filter_map(params, position) do
    params
    |> Enum.filter(fn param -> param.position == position end)
    |> Enum.map(fn param ->
      item = get_one(JsonDataFaker.generate(param.schema))

      p =
        case is_list(item) do
          true -> Enum.join(item, ",")
          _ -> item
        end

      {param.name, p}
    end)
  end
end
