import Config

# Print only warnings and errors during test
config :logger, level: :warn

# Configures application server port
config :<%= @app_name %>,
  http: [port: 4001]
