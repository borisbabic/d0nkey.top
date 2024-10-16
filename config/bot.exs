import Config

import_config "config_bot.exs"

config :backend,
  warmup_cache: true,
  enable_bot: true,
  auto_migrate: false,
  thl_discord_id: 534_455_756_129_435_649,
  nostrum_slash_command_target: :global,
  dt_insert_listener: true

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
