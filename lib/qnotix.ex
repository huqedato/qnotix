defmodule Qnotix do
  require Logger
  alias Qnotix.TopicsManager

  @moduledoc """
  Qnotix is a Pub/Sub notification system written in Elixir based on just `Plug Cowboy` module and websockets.
  
  
  ## Description
  
  Qnotix is a topic-based system, highly resilient, each topic running within its own, independent, supervised procees.
  
  The Pub side feeds events using HTML Post API.
  The Sub side is dispatching events through websocket connection.
  
  Both Pub and Sub sides depend and evolve on a named topic and its own port number.
  
  The format of messages, JSON, is similar to that of [ntfy](https://ntfy.sh/docs/subscribe/api/#json-message-format).
  As Sub client, the [ntfy Android app](https://ntfy.sh/docs/subscribe/phone/) must be used, the flavor available on [F-Droid](https://f-droid.org/en/packages/io.heckel.ntfy/) (no Firebase). *Not being an Android developer, I would greatly appreciate support for building a dedicated Android client for Qnotix*.
  
  
  """

  ###################
  # Qnotix main APIs
  ###################

  @doc """
  
  Launch a new topic.
  
  ## Parameters
    -  topic(string): the name of new topic
  
  
  ## Examples
  ```
    iex(1)> Qnotix.newTopic("Hello")
    [notice] Topic Hello started on port 4001
    {:ok, 4001}
  ```
  """
  def newTopic(topic) when is_binary(topic) and byte_size(topic) > 0 do
    port = getFreePort(Application.get_env(:qnotix, :wsStartPort))
    {flag, msg} = TopicsManager.start_child({topic, port})

    case flag do
      :ok ->
        Logger.notice("Topic #{topic} started on port #{port}")
        {:ok, port}

      :error ->
        Logger.error("Topic #{topic} didn't start. Reason:")
        IO.inspect(msg)
        {:error, nil}
    end
  end

  @doc """
  Launch a new topic on the desired port
  
  ## Parameters
    - topic(string): the name of new topic
    - port(integer): port number
  
  ## Examples
  ```
    iex(1)> Qnotix.newTopic("hello",4321)
    [notice] Topic hello started on port 4321
    {:ok, 4321}
  ```
  """
  @spec newTopic(binary, integer) :: {:error, nil} | {:ok, integer}
  def newTopic(topic, port) when is_binary(topic) and byte_size(topic) > 0 and is_integer(port) do
    {msg, _} = TopicsManager.start_child({topic, port})

    case msg do
      :ok ->
        Logger.notice("Topic #{topic} started on port #{port}")
        {:ok, port}

      :error ->
        Logger.error("Topic #{topic} didn't start")
        {:error, nil}
    end
  end

  @doc """
  Prints all running topics
  
  ## Examples
  ```
  iex(1)> Qnotix.getTopics
    [
      %{pid: "#PID<0.398.0>", port: 4321, topic: "hello"},
      %{pid: "#PID<0.507.0>", port: 4001, topic: "friend"}
      %{pid: "#PID<0.523.0>", port: 4005, topic: "foe"}
    ]
  ```
  """
  @spec getTopics :: nil | [...]
  def getTopics do
    topics =
      Registry.select(:topics, [{{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}])
      |> Enum.sort()
      |> Enum.map(fn {{topic, port}, pid} = _ ->
        %{topic: topic, port: port, pid: inspect(pid)}
      end)

    case topics do
      [_h | _t] -> topics
      [] -> nil
    end
  end

  @doc """
  Returns the port for a certain topic
  
  ## Parameters
    - topic(string): the name of new topic
  
  ## Example
  ```
  iex(1)> Qnotix.getPortFromTopic("hello")
  4321
  ```
  """
  def getPortFromTopic(topic) do
    {{_, port}, _} =
      Registry.select(:topics, [{{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}])
      |> Enum.find(fn {{regTopic, _port}, _pid} = _ -> regTopic == topic end)

    port
  end

  @doc """
  Kills a topic by its name or by port
  
  ## Parameters
    - topic(string): the name of new topic
    or
    - port(integer)
  
  ## Example
    ```
    iex(3)> Qnotix.endTopic("hello")
    :ok
    ```
  """
  @spec endTopic(binary | integer) ::
          :no_such_topic | :no_topic_on_port | :ok | {:error, :not_found}
  def endTopic(topic) when is_binary(topic) and byte_size(topic) > 0 do
    proc =
      Registry.select(:topics, [{{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}])
      |> Enum.filter(fn {{regTopic, _port}, _pid} = _ -> regTopic == topic end)

    case proc do
      [{{_regTopic, _port}, pid}] -> DynamicSupervisor.terminate_child(TopicsManager, pid)
      _ -> :no_such_topic
    end
  end

  def endTopic(port) when is_integer(port) do
    proc =
      Registry.select(:topics, [{{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}])
      |> Enum.filter(fn {{_regTopic, regPort}, _pid} = _ -> regPort == port end)

    case proc do
      [{{_regTopic, _port}, pid}] -> DynamicSupervisor.terminate_child(TopicsManager, pid)
      _ -> :no_topic_on_port
    end
  end

  #####################
  # Private functions
  #####################
  defp getFreePort(port) do
    case :gen_tcp.listen(port, [:binary]) do
      {:ok, socket} ->
        :ok = :gen_tcp.close(socket)
        port

      {:error, :eaddrinuse} ->
        getFreePort(port + 1)
    end
  end
end
