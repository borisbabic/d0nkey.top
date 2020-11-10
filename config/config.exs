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
    {"7 7 * * *", fn -> Backend.EsportsEarnings.auto_update() end},
    {"13 * * * *", fn -> Backend.MastersTour.qualifiers_update() end},
    {"37 3 * * *", fn -> Backend.HearthstoneJson.update_cards() end},
    {"1 * * * *", fn -> Backend.MastersTour.sign_me_up() end},
    {"* * * * *", fn -> Backend.Streaming.update_streamer_decks() end},
    {"* * * * *", fn -> Backend.Leaderboards.save_current() end}
  ]

config :backend,
  ecto_repos: [Backend.Repo]

# Configures the endpoint
config :backend, BackendWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Hm4BqSotrad1PnidcjfF1FVR5I2Yw4YXEs64ZczPSBkDDXBsTPjMyC9TmGXJ3Kh2",
  render_errors: [view: BackendWeb.ErrorView, accepts: ~w(html json)],
  # pubsub: [name: Backend.PubSub, adapter: Phoenix.PubSub.PG2]
  pubsub_server: Backend.PubSub,
  live_view: [signing_salt: "Can't Touch This"]

config :ueberauth, Ueberauth,
  providers: [
    bnet: {Ueberauth.Strategy.Bnet, []}
  ]

config :ueberauth, Ueberauth.Strategy.Bnet.OAuth,
  # System.get_env("BNET_CLIENT_ID"),
  client_id: "3f839935169e4d6e9c1fc893301d242a",
  client_secret: System.get_env("BNET_CLIENT_SECRET") || "",
  region: "eu"

config :backend, Backend.UserManager.Guardian,
  issuer: "d0nkey.top",
  secret_key: "CyjJAVTbtJgJwS+NbkbTpVTPDJeMKqcn+GakxrO4E5j/kB3SgcgF3CqfsxpxzQKM"

# auto sign me up
config :backend,
  esports_earnings_api_key: "",
  su_token: System.get_env("SIGNUP_TOKEN") || nil,
  su_user_id: "581f5548583dd73a0351b867",
  su_battletag_full: "D0nkey#2470",
  su_battlenet_id: "406233814",
  su_discord: "D0nkey#8994",
  su_slug: "d0nkey",
  warmup_cache: false,
  auto_migrate: false,
  hearthstone_json_fetch_fresh: true,
  su_regions: ["Europe", "Americas"],
  twitch_client_id: System.get_env("TWITCH_CLIENT_ID"),
  twitch_client_secret: System.get_env("TWITCH_CLIENT_SECRET"),
  admin_pass: "admin",
  admin_config_vars_cutoff_date: "3000-12-31"

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
