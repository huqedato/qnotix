defmodule Qnotix.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, [keys: :unique, name: :topics]},
      {Registry, [keys: :unique, name: :stores]},
      {Plug.Cowboy,
       scheme: :http,
       plug: Qnotix.AppRouter,
       options: [port: Application.get_env(:qnotix, :backendPort)]},
      {DynamicSupervisor, name: Qnotix.TopicsManager, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: Qnotix.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
