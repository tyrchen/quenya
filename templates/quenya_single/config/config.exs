# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures quenya API pipelines
config :quenya_util,
  use_fake_handler: true,
  use_response_validator: false,
  apis: %{}

# Configures ex_json_schema to use QuenyaUtil.FormatValidator for unkown format
config :ex_json_schema, :custom_format_validator, {QuenyaUtil.FormatValidator, :validate}

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures application server port
config :<%= @app_name %>,
  http: [port: 4000]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
