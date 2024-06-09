# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :backend, BackendWeb.Endpoint,
  url: [host: "localhost"],
  http: [protocol_options: [max_request_line_length: 32_768, max_header_value_length: 32_768]],
  secret_key_base: "Hm4BqSotrad1PnidcjfF1FVR5I2Yw4YXEs64ZczPSBkDDXBsTPjMyC9TmGXJ3Kh2",
  render_errors: [view: BackendWeb.ErrorView, accepts: ~w(html json)],
  # pubsub: [name: Backend.PubSub, adapter: Phoenix.PubSub.PG2]
  pubsub_server: Backend.PubSub,
  live_view: [signing_salt: "Can't Touch This"]

config :ueberauth, Ueberauth,
  providers: [
    bnet: {Ueberauth.Strategy.Bnet, []},
    patreon: {
      Ueberauth.Strategy.Patreon,
      [default_scope: "identity"]
    },
    twitch:
      {Ueberauth.Strategy.Twitch, [callback_url: "http://localhost:8994/auth/twitch/callback"]}
  ]

config :ueberauth, Ueberauth.Strategy.Patreon.OAuth,
  client_id: System.get_env("PATREON_CLIENT_ID"),
  client_secret: System.get_env("PATREON_CLIENT_SECRET"),
  redirect_uri: System.get_env("PATREON_REDIRECT_URI")

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

base_bnet_oath = [
  client_id: "3f839935169e4d6e9c1fc893301d242a",
  client_secret: System.get_env("BNET_CLIENT_SECRET") || ""
]

bnet_oath =
  case System.get_env("BNET_REGION") do
    r when r in ["us", "apac", "eu"] -> [{:region, r} | base_bnet_oath]
    _ -> base_bnet_oath
  end

config :ueberauth, Ueberauth.Strategy.Bnet.OAuth, bnet_oath

config :backend, Backend.UserManager.Guardian,
  issuer: "d0nkey.top",
  secret_key: "CyjJAVTbtJgJwS+NbkbTpVTPDJeMKqcn+GakxrO4E5j/kB3SgcgF3CqfsxpxzQKM"

hdt_plugin_latest_version = "0.3.1"
# auto sign me up
config :backend,
  su_token: System.get_env("SIGNUP_TOKEN") || nil,
  su_user_id: "581f5548583dd73a0351b867",
  su_battletag_full: "D0nkey#2470",
  enable_twitch_bot: false,
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
  dt_insert_listener: true,
  twitch_client_id: System.get_env("TWITCH_CLIENT_ID"),
  twitch_client_secret: System.get_env("TWITCH_CLIENT_SECRET"),
  bnet_client_id: bnet_client_id,
  bnet_client_secret: bnet_client_secret,
  # actually d0nkey discord
  thl_discord_id: 666_596_230_100_549_652,
  patreon_campaign_id: 5_162_559,
  patreon_access_token: System.get_env("PATREON_ACCESS_TOKEN"),
  admin_pass: "admin",
  enable_nitropay: true,
  favicon: "/favicon.ico",
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
  default_nitropay_ads_txt_url: "https://api.nitropay.com/v1/ads-909.txt",
  ads_config: [
    {"d0nkey.top",
     %{enable_adsense: false, nitropay_url: "https://api.nitropay.com/v1/ads-909.txt"}},
    {"hsguru.com",
     %{enable_adsense: false, nitropay_url: "https://api.nitropay.com/v1/ads-1847.txt"}}
  ],
  ecto_repos: [Backend.Repo],
  admin_config_vars_cutoff_date: "3000-12-31"

config :tesla, adapter: Tesla.Adapter.Hackney

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, level: :warning

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :nostrum,
  gateway_intents: [
    :guild_messages,
    :direct_messages,
    :message_content
  ],
  num_shards: :auto

config :torch,
  otp_app: :backend,
  template_format: "eex"

config :phoenix_meta_tags,
  title: "HSGuru",
  description: "Hearthstone Decks, Stats, Streamer Decks, and Esports Info",
  url: "www.hsguru.com"

config :esbuild,
  version: "0.20.2",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__)
  ]

config :tailwind,
  version: "3.4.3",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/css/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
