defmodule Quenya.Plug.RoutePlug do
  @moduledoc """
  Plug for executing a route. To use it:

      get "/todo/:todoId", to: Quenya.Plug.RoutePlug, init_opts: [
        preprocessors: [RequestValidatorPlug],
        postprocessors: [ResponseValidatorPlug],
        handlers: [RouteHandler]
      ])

  Note this plug shall be used after Plug.Parsers since it will access request body (if any)
  ## Options

    * `:preprocessors` - a list of plugs, execute in order before executing handlers
    * `:handlers` - a list of plugs to process request and generate response
    * `:postprocessors` - a list of plugs that will be executed in order before send
  """

  alias Plug.Conn

  @behaviour Plug

  @spec init(keyword()) :: keyword()
  def init(opts) do
    handlers = opts[:handlers] || []

    if Enum.empty?(handlers) do
      raise "You must define at least one handler"
    end

    opts
  end

  @spec call(Conn.t(), keyword()) :: Conn.t()
  def call(conn, opts) do
    conn = register_postprocessors(conn, opts[:postprocessors])

    conn = Enum.reduce_while(opts[:preprocessors] || [], conn, &apply_pipe(&1, &2))

    case conn.halted do
      false -> Enum.reduce_while(opts[:handlers] || [], conn, &apply_pipe(&1, &2))
      _ -> conn
    end
  end

  defp apply_pipe({mod, opts}, conn) do
    case apply(mod, :call, [conn, opts]) do
      %Plug.Conn{halted: true} = result -> {:halt, result}
      %Plug.Conn{} = result -> {:cont, result}
      other -> raise "All pipes must return Plug.Conn.t. Got #{inspect(other)}"
    end
  end

  defp register_postprocessors(conn, processors) when is_list(processors) do
    processors
    |> Enum.reverse()
    |> Enum.reduce(conn, fn {mod, opts}, acc ->
      Conn.register_before_send(acc, &apply(mod, :call, [&1, opts]))
    end)
  end

  defp register_postprocessors(conn, _), do: conn
end
