defmodule Hakkawine.MixProject do
  use Mix.Project

  def project do
    [
      app: :hakkawine,
      version: "0.1.0",
      elixir: "~> 1.20",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  def application do
    [
      mod: {Hakkawine.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.8.9"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.2.0"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.9"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.5", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:daisyui,
       github: "saadeghi/daisyui",
       tag: "v5.7.50",
       sparse: "packages/bundle",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.16"},
      {:req, "~> 0.5"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.3"},
      {:bandit, "~> 1.8"},
      # Background and asynchronous job processing
      {:oban, "~> 2.23"},
      # Redis client
      {:redix, "~> 1.1"},
      # Password hashing and encryption
      {:argon2_elixir, "~> 4.0"},
      # Timezone and time formatting
      {:tz, "~> 0.28.2"},
      # PostgreSQL network address types
      {:ecto_network, "~> 1.6.1"},
      # Client IP address handling
      {:remote_ip, "~> 1.2"},
      # User-Agent parsing (browser, OS, and device detection)
      {:ua_parser, "~> 1.8"},
      # Geolocation and IP-based location lookup
      {:locus, "~> 2.3"},
      # Compression and static file handling
      {:brotli, "~> 0.3.4"},
      # Environment variable management (development only)
      {:dotenvy, "~> 1.0", only: [:dev]}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": [
        "compile",
        "tailwind hakkawine",
        "esbuild hakkawine",
        &copy_vendor_js/1
      ],
      "assets.deploy": [
        "tailwind hakkawine --minify",
        "esbuild hakkawine --minify",
        &copy_vendor_js/1,
        "phx.digest"
      ],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end

  def copy_vendor_js(_args \\ nil) do
    js_files = []

    source_dir = "assets/vendor"
    target_dir = "priv/static/assets/js"

    File.mkdir_p!(target_dir)

    Enum.each(js_files, fn filename ->
      source = Path.join(source_dir, filename)
      target = Path.join(target_dir, filename)

      if File.exists?(source) do
        File.cp!(source, target)
      else
        IO.puts("[Vendor Sync] Warning: Vendor JS file not found -> #{source}")
      end
    end)
  end
end
