defmodule MarketData.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MarketDataWeb.Telemetry,
      MarketData.Repo,
      {DNSCluster, query: Application.get_env(:market_data, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MarketData.PubSub},
      # Start the Finch HTTP client for making HTTP requests
      {Finch, name: MarketData.Finch},
      # Start a worker by calling: MarketData.Worker.start_link(arg)
      # {MarketData.Worker, arg},
      # Start to serve requests, typically the last entry
      MarketDataWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MarketData.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MarketDataWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
