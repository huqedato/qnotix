defmodule Qnotix.Server do
  @moduledoc false
  use Supervisor
  alias Qnotix.{Store, WsRouter, Socket}

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: via_tuple(init_arg))
  end

  @impl true
  def init(init_arg) do
    {topic, port} = init_arg

    children = [
      {Plug.Cowboy,
       scheme: :http, plug: WsRouter, options: [dispatch: dispatch(topic), port: port, ref: topic]},
      {Registry, keys: :duplicate, name: String.to_atom(topic)},
      %{
        id: "#{topic}@#{to_string(port)}$store",
        start: {Store, :start_link, ["#{topic}@#{to_string(port)}$store"]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one, name: topic)
  end

  defp via_tuple(topic) do
    {:via, Registry, {:topics, topic}}
  end

  defp dispatch(path) do
    [
      {:_,
       [
         {"/" <> path <> "/ws", Socket, path},
         {:_, Plug.Cowboy.Handler, {WsRouter, []}}
       ]}
    ]
  end
end
