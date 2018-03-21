use Mix.Config

# set server to true for release build via distillery

config :exdaas, ExDaasWeb.Endpoint,
  load_from_system_env: true,
  url: [scheme: "http"],
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE"),
  server: true

  config :logger, level: :warn
