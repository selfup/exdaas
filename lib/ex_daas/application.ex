defmodule ExDaas.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(ExDaasWeb.Endpoint, []),
      supervisor(ExDaas.Supervisor, []),
    ]

    opts = [strategy: :one_for_one, name: ExDaas.Main.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ExDaasWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
