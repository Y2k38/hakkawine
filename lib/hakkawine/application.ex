defmodule Hakkawine.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    redis_config = Application.get_env(:hakkawine, :redis)

    redix_opts =
      redis_config
      |> Enum.reject(fn {_k, v} -> v in [nil, "", "nil"] end)
      |> Keyword.put(:name, :redix)

    children = [
      HakkawineWeb.Telemetry,
      Hakkawine.Repo,
      {DNSCluster, query: Application.get_env(:hakkawine, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Hakkawine.PubSub},

      {Task, fn -> Hakkawine.System.load_settings!() end},

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
end
