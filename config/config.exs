# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :backend, QuantumScheduler,
  jobs: [
    {"0 12 * * Mon", fn -> Backend.Fantasy.advance_gm_round() end},
    {"13 * * * *", fn -> Backend.MastersTour.qualifiers_update() end},
    {"37 3 * * *", fn -> Backend.HearthstoneJson.update_cards() end},
    {"37 13 * * *", fn -> Backend.ReqvamTop100Tweeter.check_and_tweet() end},
    {"37 5 * * *", fn -> Backend.PrioritizedBattletagCache.update_cache() end},
    # {"1 * * * *", fn -> Backend.MastersTour.sign_me_up() end},
    {"17 * * * *", fn -> Backend.DeckFeedItemUpdater.update_deck_items() end},
    {"18 * * * *", fn -> Backend.Feed.FeedBag.update() end},
    {"47 * * * *", fn -> Backend.Feed.decay_feed_items() end},
    {"48 * * * *", fn -> Backend.Feed.FeedBag.update() end},
    {"* * * * *", fn -> Backend.Grandmasters.update() end},
    {"53 * * * *", fn -> Backend.PlayerIconBag.update() end},
    {"* * * * *", fn -> Backend.Streaming.update_hdt_streamer_decks() end},
    {"57 * * * *", fn -> Backend.MastersTour.refresh_current_invited() end},
    {"* * * * *", fn -> Backend.AdsTxtCache.update() end},
    {"41 * * * *", fn -> Backend.PonyDojo.update() end},
    {"43 * * * *", fn -> Backend.DiscordBot.update_all_guilds(5000) end},
    {"*/2 * * * *", fn -> Backend.Leaderboards.save_current() end},
    {"37 17 * * *", fn -> Backend.Hearthstone.update_metadata() end},
    {"11 * * * *", fn -> Backend.Hearthstone.CardBag.refresh_table() end},
    {"*/9 * * * *", fn -> Backend.Leaderboards.refresh_latest() end},
    # {"* * * * *", fn -> Backend.HSReplay.handle_live_decks() end},
    {"* * * * *", fn -> Backend.LatestHSArticles.update() end}
  ]

bnet_client_id =
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
    bnet: {Ueberauth.Strategy.Bnet, []},
    twitch:
      {Ueberauth.Strategy.Twitch, [callback_url: "http://localhost:8994/auth/twitch/callback"]}
  ]

bnet_client_id =
  System.get_env("BNET_CLIENT_ID") ||
    raise "environment variable BNET_CLIENT_ID is missing."

bnet_client_secret =
  System.get_env("BNET_CLIENT_SECRET") ||
    raise "environment variable BNET_CLIENT_SECRET is missing."

config :ueberauth, Ueberauth.Strategy.Twitch.OAuth,
  client_id: bnet_client_id,
  client_secret: bnet_client_secret,
  send_redirect_uri: false

config :ueberauth, Ueberauth.Strategy.Bnet.OAuth,
  # System.get_env("BNET_CLIENT_ID"),
  client_id: "3f839935169e4d6e9c1fc893301d242a",
  client_secret: System.get_env("BNET_CLIENT_SECRET") || ""

config :backend, Backend.UserManager.Guardian,
  issuer: "d0nkey.top",
  secret_key: "CyjJAVTbtJgJwS+NbkbTpVTPDJeMKqcn+GakxrO4E5j/kB3SgcgF3CqfsxpxzQKM"

hdt_plugin_latest_version = "0.3.1"
# auto sign me up
config :backend,
  su_token: System.get_env("SIGNUP_TOKEN") || nil,
  su_user_id: "581f5548583dd73a0351b867",
  su_battletag_full: "D0nkey#2470",
  su_battlenet_id: "406233814",
  su_discord: "D0nkey#8994",
  su_slug: "d0nkey",
  goatcounter_analytics: false,
  cloudflare_analytics: false,
  warmup_cache: false,
  disable_hsreplay: true,
  auto_migrate: false,
  hearthstone_json_fetch_fresh: true,
  su_regions: ["Europe"],
  twitch_client_id: System.get_env("TWITCH_CLIENT_ID"),
  twitch_client_secret: System.get_env("TWITCH_CLIENT_SECRET"),
  bnet_client_id: bnet_client_id,
  bnet_client_secret: bnet_client_secret,
  # actually d0nkey discord
  thl_discord_id: 666_596_230_100_549_652,
  admin_pass: "admin",
  enable_nitropay: true,
  twitch_bot_chats: ["d0nkeyhs", "d0nkeytop"],
  gm_stream_send_tweet: false,
  twitch_bot_config: [
    user: "d0nkeytop",
    pass: System.get_env("TWITCH_BOT_OAUTH"),
    handler: TwitchBot.Handler
  ],
  gm_stream_twitter_info: [
    consumer_key: System.get_env("GMS_CONSUMER_KEY"),
    consumer_secret: System.get_env("GMS_CONSUMER_SECRET"),
    access_token: System.get_env("GMS_ACCESS_TOKEN"),
    access_token_secret: System.get_env("GMS_ACCESS_TOKEN_SECRET")
  ],
  req_t100_twitter_info: [
    consumer_key: System.get_env("REQT100_CONSUMER_KEY"),
    consumer_secret: System.get_env("REQT100_CONSUMER_SECRET"),
    access_token: System.get_env("REQT100_ACCESS_TOKEN"),
    access_token_secret: System.get_env("REQT100_ACCESS_TOKEN_SECRET")
  ],
  nitropay_demo: true,
  nostrum_slash_commands: [Bot.SlashCommands.MTQCommand],
  # d0nkey guild id
  nostrum_slash_command_target: 666_596_230_100_549_652,
  hdt_plugin_latest_version: hdt_plugin_latest_version,
  hdt_plugin_latest_file: "hdt_plugin/#{hdt_plugin_latest_version}.dll",
  nitropay_ads_txt_url: "https://api.nitropay.com/v1/ads-909.txt",
  enable_adsense: true,
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
  queues: [
    default: 10,
    battlefy_lineups: 20,
    grandmasters_lineups: 3,
    gm_stream_live: 4,
    hsreplay_deck_mapper: 1,
    hsreplay_streamer_deck_inserter: 1
  ]

config :phoenix_meta_tags,
  title: "d0nkey",
  description: "Hearthstone Streamer Decks and Esports Info",
  url: "d0nkey.top"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
