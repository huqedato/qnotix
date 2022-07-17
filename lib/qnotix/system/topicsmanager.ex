defmodule Qnotix.TopicsManager do
  @moduledoc false
  use DynamicSupervisor
  alias Qnotix.Server

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(topic_name) do
    child_specification = {Server, topic_name}
    DynamicSupervisor.start_child(__MODULE__, child_specification)
  end

  @impl true
  def init(init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [init_arg]
    )
  end
end
