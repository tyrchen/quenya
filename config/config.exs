import Config

# Configures ex_json_schema to use Quenya.FormatValidator for unkown format
config :ex_json_schema, :custom_format_validator, {Quenya.FormatValidator, :validate}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
