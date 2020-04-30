# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :backend, QuantumScheduler,
  jobs: [
    {"*/3 * * * *", fn -> Backend.HSReplay.update_latest() end},
    {"1 * * * *", fn -> Backend.MastersTour.sign_me_up() end}
  ]

config :backend,
  ecto_repos: [Backend.Repo]

# Configures the endpoint
config :backend, BackendWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Hm4BqSotrad1PnidcjfF1FVR5I2Yw4YXEs64ZczPSBkDDXBsTPjMyC9TmGXJ3Kh2",
  render_errors: [view: BackendWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Backend.PubSub, adapter: Phoenix.PubSub.PG2]

# auto sign me up
config :backend,
  su_token: System.get_env("SIGNUP_TOKEN") || nil,
  su_user_id: "581f5548583dd73a0351b867",
  su_battletag_full: "D0nkey#2470",
  su_battlenet_id: "406233814",
  su_discord: "D0nkey#8994",
  su_slug: "d0nkey",
  su_regions: ["Europe", "Americas"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :nostrum,
  num_shards: :auto

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
