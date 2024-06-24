defmodule PixelPlace.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PixelPlaceWeb.Telemetry,
      PixelPlace.Repo,
      {Ecto.Migrator, repos: Application.fetch_env!(:pixel_place, :ecto_repos)},
      {DNSCluster, query: Application.get_env(:pixel_place, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PixelPlace.PubSub},
      # Start a worker by calling: PixelPlace.Worker.start_link(arg)
      # {PixelPlace.Worker, arg},
      # Start to serve requests, typically the last entry
      PixelPlaceWeb.Endpoint,
      PixelPlaceWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PixelPlace.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PixelPlaceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
