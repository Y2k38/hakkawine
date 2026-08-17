import Config

config :hakkawine, HakkawineWeb.Endpoint,
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:hakkawine, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:hakkawine, ~w(--watch)]}
  ],
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"E,
      ~r"priv/gettext/.*\.po$"E,
      ~r"lib/hakkawine_web/router\.ex$"E,
      ~r"lib/hakkawine_web/(controllers|live|components)/.*\.(ex|heex)$"E
    ]
  ]

config :hakkawine, dev_routes: true
config :swoosh, :api_client, false

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :logger, :default_formatter, format: "$metadata[$level] $message\n"

config :phoenix_live_view,
  debug_heex_annotations: true,
  debug_attributes: true,
  enable_expensive_runtime_checks: true
