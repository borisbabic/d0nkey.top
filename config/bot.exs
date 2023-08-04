import Config

import_config "cron_bot.exs"

config :backend,
  enable_bot: true,
  dt_insert_listener: false

config :nostrum,
  # The token of your bot as a string
  token: System.get_env("DISCORD_TOKEN"),
  # The number of shards you want to run your bot under, or :auto.
  num_shards: :auto

import_config "prod.secret.exs"

# config :backend, Backend.Repo,
# username: "root",
# password: "root",
# database: "DtopDB",
# hostname: "localhost",
# port: 2470,
# show_sensitive_data_on_connection_error: true,
# pool_size: 10
