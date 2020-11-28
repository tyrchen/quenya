import Config

config :quenya,
  use_fake_handler: true,
  use_response_validator: true,
  apis: %{}

config :ex_json_schema,
       :custom_format_validator,
       {QuenyaUtil.FormatValidator, :validate}
