defmodule Qnotix.Pub do
  alias Qnotix.{Utils, Store}

  @moduledoc """
  Publisher API
  """

  @doc """
  Sends events (messages) to the Pub/Sub service.
  
  ## Parameters
   - payload(map)
  
  The message format has the following fields:
      - id(string) - compulsory
      - event = "message" - compulsory
      - topic(string) - compulsory
      - message(string) - compulsory
      - title(string) - optional
      - priority: 1, 2, 3, 4, or 5 (default 4)
      - click(url) - optional
      - tags(string array) - optional
  
  ## Example
  ```
  iex(1)> Qnotix.Pub.pub(%{"event" => "message", "id" => "FF73vmnSOnA7XLK", "topic" => "Security", "message" => "The perimeter has been breached!", "priority" => 4, "tags" => ["skull"], "title" => "Alarm",  "click" => "http://www.secincident.com/24284756"})
  :ok
  ```
  """
  @spec pub(map) :: :ok
  def pub(%{"id" => _, "message" => _, "topic" => _, "event" => "message"} = payload) do
    msg =
      payload
      |> Map.put("time", Utils.timestamp())

    store = "#{payload["topic"]}@#{to_string(Qnotix.getPortFromTopic(payload["topic"]))}$store"

    Store.clean(store)
    Store.put(store, msg)

    msg
    |> Jason.encode!()
    |> push(payload["topic"])
  end

  defp push(msg, topic) do
    Registry.dispatch(String.to_atom(topic), topic, fn entries ->
      for {pid, _} <- entries do
        Process.send(pid, msg, [])
      end
    end)
  end
end
