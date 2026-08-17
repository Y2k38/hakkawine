import Config

config :hakkawine, HakkawineWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  root: ".",
  server: true,
  version: Application.spec(:hakkawine, :vsn)

config :logger, level: :info

config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id]

config :swoosh, api_client: Swoosh.ApiClient.Req
config :swoosh, local: false
