import Config

config :backend,
  hearthstone_json_fetch_fresh: false,
  enable_bot: false

config :nostrum,
  # The token of your bot as a string
  token:
    System.get_env("DISCORD_TOKEN") ||
      "NjY3MzQyODIxNDM4NTIxMzY1.XiBVqg.Ya91ymmfYZVLdZjajii0wGMSkRc",
  # The number of shards you want to run your bot under, or :auto.
  num_shards: :auto

# Configure your database
config :backend, Backend.Repo,
  username: "root",
  password: "root",
  database: "DtopDB_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  port: 2470,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :backend, BackendWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :backend, Oban, queues: false, plugins: false, repo: Backend.Repo
