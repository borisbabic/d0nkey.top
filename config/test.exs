use Mix.Config

# Configure your database
config :backend, Backend.Repo,
  username: "root",
  password: "root",
  database: "DtopDB_test",
  hostname: "localhost",
  port: 2470,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :backend, BackendWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
