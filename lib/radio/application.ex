defmodule Radio.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      RadioWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Radio.PubSub},
      # Start the Endpoint (http/https)
      RadioWeb.Endpoint,
      # Start a worker by calling: Radio.Worker.start_link(arg)
      # {Radio.Worker, arg}
      Radio.Mpd
    ]

    opts = [strategy: :one_for_one, name: Radio.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def target() do
    Application.get_env(:radio, :target)
  end

  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RadioWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
