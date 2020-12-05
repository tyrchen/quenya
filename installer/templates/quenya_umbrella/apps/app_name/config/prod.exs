import Config

# Configures application server port
config :<%= @app_name %>,
  http: [port: 8080]

# Joken configuration
config :joken,
  default_signer: {:system, "JWT_SECRET"},
  # two weeks
  default_exp: 2 * 7 * 24 * 60 * 60,
  iss: "<%= @app_name %>"
