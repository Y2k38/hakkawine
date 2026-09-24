import Config

config :hakkawine, Oban, testing: :manual
config :logger, level: :warning

config :hakkawine, HakkawineWeb.Endpoint, server: false
config :hakkawine, Hakkawine.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :swoosh, :api_client, false
config :hakkawine, Hakkawine.Mailer, adapter: Swoosh.Adapters.Test

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :phoenix,
  sort_verified_routes_query_params: true
