# Qnotix

Qnotix is a Pub/Sub notification system written in Elixir based on just websockets implementation of [Plug.Cowboy](https://github.com/elixir-plug/plug_cowboy). 



## Description

Qnotix is a topic-based system, highly resilient, each topic running within its own, independent, supervised processes.

The Pub side feeds events by HTML POST API.
The Sub side is dispatching events as push-notifications to clients through websocket connection. 

Both Pub and Sub sides depend and evolve on a named topic and its own port number.

The format of messages, JSON, is similar to that of [ntfy](https://ntfy.sh/docs/subscribe/api/#json-message-format).
As Sub client, the [ntfy Android app](https://ntfy.sh/docs/subscribe/phone/) must be used, the flavor available on [F-Droid](https://f-droid.org/en/packages/io.heckel.ntfy/), without Firebase. *Not being an Android developer, I would greatly appreciate support for building a dedicated Android client for Qnotix*.

Find more details at [Qnotix documentation on Hexdocs](http://hexdocs.pm/qnotix).



>This application (though slightly modified) is actually in production since March 2022 for a private surveillance company, serving more than 150 subscribers from 17 publishers.



## Installation
Copy this repo via git clone `https://github.com/huqedato/qnotix` or download it.

Alternatively, as a dependency, add `qnotix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:qnotix, "~> 1.0.0"}
  ]
end
```

Then run `mix deps.get`.


Set application's management port (*backendPort*), start port numbering for topics (*wsStartPort*) and event lifetime in days (*msgDeadAfter*) in `runtime.exs`.



## Configuration & Usage


 
Launch server: `iex -S mix`

Register a new topic: `Qnotix.newTopic(topic_name)`. 

Launch a new topic on the desired port `Qnotix.newTopic(topic_name, port)`.

Check the web management interface for supervising topics and ports, registering new topics, kill topics etc.

By example, considering the server running locally on port 4000 and a topic named *myTopic* on port 4111 one can:
- access web management interface: `http://localhost:4000`
- register a new topic: `http://localhost:4000/new`
- kill topic by name or port `http://localhost:4000/end`
- publish notification to *myTopic* by POST method to `http://localhost:4111/pub`
- web page to publish mock notifications to all subscribers for *myTopic* on `http://localhost:4111/`



Qnotix is only compatible and working with [ntfy Android client app](https://ntfy.sh/docs/subscribe/phone/). The topic format/url is `ws://host:port/topic_name/ws`. Ex: `ws://192.168.1.1:4001/myTopic/ws`


## Documentation
http://hexdocs.pm/qnotix


## TODO
Kindly asking the Elixir community's support for:
- development of a dedicated Android/IOS notification client for Qnotix
- improved documentation
- system extension for providing data streaming from 3rd party applications, services, or IoT devices (Nerves integration?)
- scalability testing on distributed environment  - multiple Erlang nodes, clustering
- add security layer



>As we lack expertise in mobile apps development we would greatly appreciate the Community's involvement for development of a dedicated notification client for Android/IOS. 


## License
Copyright © 2022 Quda Theo

This software is released under **[AGPL-3.0-or-later](https://www.gnu.org/licenses/agpl-3.0.html)**.
