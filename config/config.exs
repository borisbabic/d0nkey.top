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
    {"0 12 * * Mon", fn -> Backend.Fantasy.advance_gm_round() end},
    {"13 * * * *", fn -> Backend.MastersTour.qualifiers_update() end},
    {"37 3 * * *", fn -> Backend.HearthstoneJson.update_cards() end},
    {"37 5 * * *", fn -> Backend.PrioritizedBattletagCache.update_cache() end},
    {"1 * * * *", fn -> Backend.MastersTour.sign_me_up() end},
    {"17 * * * *", fn -> Backend.DeckFeedItemUpdater.update_deck_items() end},
    {"47 * * * *", fn -> Backend.Feed.decay_feed_items() end},
    {"* * * * *", fn -> Backend.Grandmasters.update() end},
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
  goatcounter_analytics: false,
  warmup_cache: false,
  auto_migrate: false,
  hearthstone_json_fetch_fresh: true,
  su_regions: ["Europe"],
  twitch_client_id: System.get_env("TWITCH_CLIENT_ID"),
  twitch_client_secret: System.get_env("TWITCH_CLIENT_SECRET"),
  admin_pass: "admin",
  gm_stream_send_tweet: false,
  gm_stream_twitter_info: [
    consumer_key: System.get_env("GMS_CONSUMER_KEY"),
    consumer_secret: System.get_env("GMS_CONSUMER_SECRET"),
    access_token: System.get_env("GMS_ACCESS_TOKEN"),
    access_token_secret: System.get_env("GMS_ACCESS_TOKEN_SECRET")
  ],
  admin_config_vars_cutoff_date: "3000-12-31"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, level: :warning

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :nostrum,
  num_shards: :auto

config :torch,
  otp_app: :backend,
  template_format: "eex"

config :backend, Oban,
  repo: Backend.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10, battlefy_lineups: 20, grandmasters_lineups: 3, gm_stream_live: 4]

config :phoenix_meta_tags,
  title: "d0nkey",
  description: "Hearthstone Streamer Decks and Esports Info",
  url: "d0nkey.top"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
