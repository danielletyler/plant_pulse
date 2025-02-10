defmodule PlantPulse.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PlantPulseWeb.Telemetry,
      PlantPulse.Repo,
      {DNSCluster, query: Application.get_env(:plant_pulse, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PlantPulse.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PlantPulse.Finch},
      # Start a worker by calling: PlantPulse.Worker.start_link(arg)
      # {PlantPulse.Worker, arg},
      # Start to serve requests, typically the last entry
      PlantPulseWeb.Endpoint,
      TwMerge.Cache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PlantPulse.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PlantPulseWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
