defmodule Qnotix.Store do
  @moduledoc false
  use GenServer
  require Logger

  defp msgValability, do: Application.get_env(:qnotix, :msgDeadAfter) * 60 * 60 * 24

  # INIT
  def start_link(store_name) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(store_name))
  end

  def init(_) do
    {:ok, []}
  end

  ##
  # CLIENT
  ##
  def put(store_name, value) do
    GenServer.cast(via_tuple(store_name), {:put, value})
  end

  def clean(store_name) do
    GenServer.cast(via_tuple(store_name), :clean)
  end

  def all(store_name) do
    GenServer.call(via_tuple(store_name), :all)
  end

  ##
  ## SERVER
  ##
  def handle_call(:all, _, state) do
    {:reply, state, state}
  end

  def handle_cast({:put, value}, state) do
    {:noreply, [value | state]}
  end

  def handle_cast(:clean, state) do
    {:noreply,
     state
     |> Enum.filter(fn x ->
       x["time"] + msgValability() > DateTime.utc_now() |> DateTime.to_unix()
     end)}
  end

  defp via_tuple(store_name) do
    {:via, Registry, {:stores, store_name}}
  end
end
