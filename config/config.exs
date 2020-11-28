import Config

config :ex_json_schema, :custom_format_validator, {QuenyaUtil.FormatValidator, :validate}
