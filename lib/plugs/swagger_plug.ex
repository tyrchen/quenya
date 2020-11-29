defmodule Quenya.Plug.SwaggerPlug do
  @moduledoc """
  Plug for swagger static UI. You must use Plug.Static to serve static files in priv/swagger

  Example:

      # in your router file
      # before anything
      plug Plug.static, at: "/swagger/main.yml", from: {:app, "priv/spec/main.yml"}
      plug Plug.static, at: "/public", from: {:quenya, "priv/swagger"}

      # after dispatch
      get "/swagger", to: Quenya.Plug.SwaggerPlug, init_opts: [spec: "/swagger/main.json"]
      get "/swagger/main.json", to: Quenya.Plug.SwaggerPlug, init_opts: [app: :todo]

  """

  import Plug.Conn

  @behaviour Plug

  @template """
  <!-- HTML for static distribution bundle build -->
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8">
        <title>Swagger UI</title>
        <link rel="stylesheet" type="text/css" href="/public/swagger-ui.css" >
        <link rel="icon" type="image/png" href="/public/favicon-32x32.png" sizes="32x32" />
        <link rel="icon" type="image/png" href="/public/favicon-16x16.png" sizes="16x16" />
        <style>
          html
          {
            box-sizing: border-box;
            overflow: -moz-scrollbars-vertical;
            overflow-y: scroll;
          }

          *,
          *:before,
          *:after
          {
            box-sizing: inherit;
          }

          body
          {
            margin:0;
            background: #fafafa;
          }
        </style>
      </head>

      <body>
        <div id="swagger-ui"></div>

        <script src="/public/swagger-ui-bundle.js" charset="UTF-8"> </script>
        <script src="/public/swagger-ui-standalone-preset.js" charset="UTF-8"> </script>
        <script>
        var url = new URL("<%= spec %>", document.baseURI);
        window.onload = function() {
          const ui = SwaggerUIBundle({
            url: url.toString(),
            dom_id: '#swagger-ui',
            deepLinking: true,
            presets: [
              SwaggerUIBundle.presets.apis,
              SwaggerUIStandalonePreset
            ],
            plugins: [
              SwaggerUIBundle.plugins.DownloadUrl
            ],
            layout: "StandaloneLayout"
          })

          window.ui = ui
        }
      </script>
      </body>
    </html>
  """

  @spec init(keyword()) :: keyword()
  def init(opts) do
    opts
  end

  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, opts) do
    case String.ends_with?(conn.request_path, "main.json") do
      true ->
        filename = Path.join(Application.app_dir(opts[:app]), "priv/spec/main.yml")
        {:ok, spec} = Quenya.Parser.parse(filename)
        body = Jason.encode!(spec)
        etag = :crypto.hash(:md5, body) |> Base.encode16(case: :lower)

        conn
        |> put_resp_header("etag", etag)
        |> send_resp(200, body)

      _ ->
        spec = opts[:spec]
        body = EEx.eval_string(@template, spec: spec)
        send_resp(conn, 200, body)
    end
  end
end
