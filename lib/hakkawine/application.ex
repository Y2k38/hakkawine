defmodule Hakkawine.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Redis
    redis_config = Application.get_env(:hakkawine, :redis)

    redix_opts =
      redis_config
      |> Enum.reject(fn {_k, v} -> v in [nil, "", "nil"] end)
      |> Keyword.put(:name, :redix)

    # MaxMind GeoIP
    init_geoip()

    children = [
      HakkawineWeb.Telemetry,
      Hakkawine.Repo,
      {DNSCluster, query: Application.get_env(:hakkawine, :dns_cluster_query) || :ignore},
      {Oban, Application.fetch_env!(:hakkawine, Oban)},
      {Phoenix.PubSub, name: Hakkawine.PubSub},
      Hakkawine.System.SettingLoader,

      # Start a worker by calling: Hakkawine.Worker.start_link(arg)
      # {Hakkawine.Worker, arg},
      # Start to serve requests, typically the last entry
      {Redix, redix_opts},
      HakkawineWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hakkawine.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HakkawineWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp init_geoip() do
    config = Application.get_env(:hakkawine, :geoip, [])

    if Keyword.get(config, :enabled, true) do
      db_dir = Keyword.get(config, :database_dir)
      auto_download? = Keyword.get(config, :auto_download, false)

      File.mkdir_p!(db_dir)

      if auto_download? do
        country_source = {:maxmind, "GeoLite2-Country"}
        asn_source = {:maxmind, "GeoLite2-ASN"}

        :locus.start_loader(:country, country_source,
          database_cache_file: Path.join(db_dir, "GeoLite2-Country.mmdb.gz")
        )

        :locus.start_loader(:asn, asn_source,
          database_cache_file: Path.join(db_dir, "GeoLite2-ASN.mmdb.gz")
        )
      else
        country_source = Path.join(db_dir, "GeoLite2-Country.mmdb")
        asn_source = Path.join(db_dir, "GeoLite2-ASN.mmdb")

        :locus.start_loader(:country, country_source)
        :locus.start_loader(:asn, asn_source)
      end

      require Logger

      Logger.info(
        "[GeoIP] locus started. Mode: #{if auto_download?, do: "Auto-Download", else: "Offline Local .mmdb"}"
      )
    end
  end
end
