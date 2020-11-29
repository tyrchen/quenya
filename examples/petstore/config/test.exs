import Config

# Print only warnings and errors during test
config :logger, level: :warn

# Configures application server port
config :petstore,
  http: [port: 4001]
