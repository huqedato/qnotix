defmodule Qnotix.Socket do
  @moduledoc false
  require Logger
  alias Qnotix.{Utils, Store}

  @behaviour :cowboy_websocket
  @timeout :infinity
  @cleanStoreInterval 1_000 * 60 * 60

  ######################
  # Websocket init
  ######################
  def init(request, topic_name) do
    state = %{
      topic: topic_name,
      storeName: "#{topic_name}@#{to_string(request.port)}$store"
    }

    opt = %{idle_timeout: @timeout}
    {:cowboy_websocket, request, state, opt}
  end

  def websocket_init(state) do
    String.to_atom(state.topic)
    |> Registry.register(state.topic, {})

    Logger.info("Client joined topic '#{state[:topic]}' with PID #{inspect(self())}")
    open = %{id: Utils.randomString(), time: Utils.timestamp(), event: "open", topic: state.topic}

    Process.send(self(), Jason.encode!(open), [])

    Store.all(state.storeName)
    |> Enum.each(fn msg -> Process.send(self(), Jason.encode!(msg), []) end)

    pid = self()
    Task.async(fn -> cleanStoreTask(pid, state.storeName) end)

    {:ok, state}
  end

  ######################
  # Websocket callbacks
  ######################

  def websocket_handle(_frame, state) do
    {:ok, state}
  end

  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end

  def terminate(_reason, _req, state) do
    Logger.info("Client #{inspect(self())} on topic '#{state[:topic]}' terminated.")
    :ok
  end

  defp cleanStoreTask(pid, store) do
    Store.clean(store)
    :timer.sleep(@cleanStoreInterval)
    if Process.alive?(pid), do: cleanStoreTask(pid, store)
  end
end
