# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

discord_token =
  System.get_env("DISCORD_TOKEN") ||
    raise """
    environment variable DISCORD_TOKEN is missing.
    this is needed for the bot
    """

admin_pass =
  System.get_env("ADMIN_PASS") ||
    raise "environment variable ADMIN_PASS is missing."

admin_config_vars_cutoff_date = System.get_env("ADMIN_CONFIG_VARS_CUTOFF_DATE") || "2020-10-12"

config :backend,
  admin_pass: admin_pass,
  admin_config_vars_cutoff_date: admin_config_vars_cutoff_date

config :backend, Backend.Repo,
  ssl: true,
  timeout: 25_000,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

signing_salt =
  System.get_env("LIVE_SIGNING_SALT") ||
    raise "environment variable LIVE_SIGNING_SALT is missing."

config :backend, BackendWeb.Endpoint,
  http: [
    :inet6,
    protocol_options: [max_request_line_length: 32_768, max_header_value_length: 32_768],
    port: String.to_integer(System.get_env("PORT") || "4000")
  ],
  secret_key_base: secret_key_base,
  live_view: [signing_salt: signing_salt]

config :nostrum,
  token: discord_token

bnet_client_id =
  System.get_env("BNET_CLIENT_ID") ||
    raise "environment variable BNET_CLIENT_ID is missing."

bnet_client_secret =
  System.get_env("BNET_CLIENT_SECRET") ||
    raise "environment variable BNET_CLIENT_SECRET is missing."

config :ueberauth, Ueberauth.Strategy.Bnet.OAuth,
  client_id: bnet_client_id,
  client_secret: bnet_client_secret

guardian_secret_key =
  System.get_env("GUARDIAN_SECRET_KEY") ||
    raise "environment variable GUARDIAN_SECRET_KEY is missing."

config :backend, Backend.UserManager.Guardian, secret_key: guardian_secret_key

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :backend, BackendWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
