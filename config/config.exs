import Config

config :hakkawine,
  ecto_repos: [Hakkawine.Repo]

config :hakkawine, HakkawineWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  secret_key_base: "sUZ2Q2Y7TzJk1vJKbGy9Ug/sclc3fZ9umBN9jZLpmjlC86HWam202zdjwFS29vkf",
  render_errors: [
    formats: [html: HakkawineWeb.ErrorHTML, json: HakkawineWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Hakkawine.PubSub,
  live_view: [signing_salt: "p4FQ2Zqs1mS/tG2IaomEYyKHyh5y9fKY"]

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix_live_view,
  root_tag_attribute: "phx-r"

config :hakkawine, Hakkawine.Mailer, adapter: Swoosh.Adapters.Local

config :phoenix,
  json_library: Jason,
  static_compressors: [
    PhoenixBakery.Gzip,
    PhoenixBakery.Brotli,
    PhoenixBakery.Zstd
  ]

config :gettext, :default_locale, "en"

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

config :esbuild,
  version: "0.25.4",
  hakkawine: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

config :tailwind,
  version: "4.3.0",
  hakkawine: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

config :hakkawine, Oban,
  engine: Oban.Engines.Basic,
  queues: [
    realtime: 20,
    scheduled: 10,
    outbound: 5
  ],
  lifeline: [rescue_after: {2, :hours}],
  pruner: [max_age: {1, :day}],
  repo: Hakkawine.Repo

import_config "#{config_env()}.exs"
