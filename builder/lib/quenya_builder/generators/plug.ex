defmodule QuenyaBuilder.Generator.Plug do
  @moduledoc """
  Generate method plug
  """
  require DynamicModule
  alias QuenyaBuilder.Util

  def gen(_doc, app, name, opts \\ []) do
    IO.puts("generating plug for #{name}.")

    mod_name = Util.gen_plug_name(app, name)

    preamble = gen_preamble()
    contents = gen_call(app, name)

    DynamicModule.gen(mod_name, preamble, contents, opts)
  end

  def gen_preamble do
    quote do
      alias Plug.Conn

      def init(opts) do
        opts
      end
    end
  end

  def gen_call(app, name) do
    req_mod = Module.concat("Elixir", Util.gen_request_validator_name(app, name))
    res_mod = Module.concat("Elixir", Util.gen_response_validator_name(app, name))

    quote do
      def call(conn, opts) do
        # validate header, path, query_params and body_params
        conn = apply(unquote(req_mod), :validate, [conn])
        register_response_validator(conn, opts)
      end

      # we only need to do response validation in non production environment
      if Mix.env() != :prod do
        defp register_response_validator(conn, opts) do
          Conn.register_before_send(conn, fn conn ->
            # validate resp header and body
            apply(unquote(res_mod), :validate, [conn])
          end)
        end
      else
        defp register_response_validator(conn, _opts), do: conn
      end
    end
  end
end
