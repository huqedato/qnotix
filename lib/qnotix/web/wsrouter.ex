defmodule Qnotix.WsRouter do
  @moduledoc false

  use Plug.Router
  require EEx
  alias Qnotix.Pub

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/pub" do
    payload = Map.put(conn.body_params, "topic", getTopicFromPort(conn.port))
    Pub.pub(payload)
    send_resp(conn, 200, "Success")
  end

  get "/" do
    html =
      EEx.eval_file("lib/qnotix/web/static/publisher.mock.html",
        topic: getTopicFromPort(conn.port)
      )

    send_resp(conn, 200, html)
  end

  match _ do
    send_resp(conn, 404, "404 - nothing here")
  end

  defp getTopicFromPort(port) do
    [{{topic, _port}, _pid}] =
      Registry.select(:topics, [{{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}])
      |> Enum.filter(fn {{_regTopic, regPort}, _pid} = _ -> regPort == port end)

    topic
  end
end
