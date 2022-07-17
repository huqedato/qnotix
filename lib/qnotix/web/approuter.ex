defmodule Qnotix.AppRouter do
  @moduledoc false
  use Plug.Router
  require EEx
  require Logger
  import Qnotix

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/reg/:new" do
    {msg, port} = newTopic(new)

    resp =
      case msg do
        :ok -> "Started, port #{port}"
        :error -> "Error!"
      end

    send_resp(
      conn,
      200,
      Jason.encode!(resp)
    )
  end

  get "/end/topic/:topic" do
    msg = endTopic(topic)

    resp =
      case msg do
        :ok -> "Topic '#{topic}' ended."
        :no_such_topic -> "Topic '#{topic}' doesn't exists"
        _ -> "Error"
      end

    send_resp(
      conn,
      200,
      Jason.encode!(resp)
    )
  end

  get "/end/port/:port" do
    msg = endTopic(String.to_integer(port))

    resp =
      case msg do
        :ok -> "Port #{port} closed."
        :no_topic_on_port -> "No topic on port #{port}"
        _ -> "Error"
      end

    send_resp(
      conn,
      200,
      Jason.encode!(resp)
    )
  end

  get "/end" do
    html = EEx.eval_file("lib/qnotix/web/static/endTopic.html")
    send_resp(conn, 200, html)
  end

  get "/topics" do
    a = getTopics()
    send_resp(conn, 200, Jason.encode!(a))
  end

  get "/new" do
    html = EEx.eval_file("lib/qnotix/web/static/webreg.html")
    send_resp(conn, 200, html)
  end

  get "/" do
    html = EEx.eval_file("lib/qnotix/web/static/index.html")
    send_resp(conn, 200, html)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
