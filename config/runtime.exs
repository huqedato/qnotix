import Config

config :qnotix,
  backendPort: 4000,
  wsStartPort: 4001,
  msgDeadAfter: 1

# se obtine cu:  Application.get_env(:qnotix, :backendPort)
# msgDeadAfter in days
