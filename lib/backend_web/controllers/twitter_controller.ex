defmodule BackendWeb.TwitterController do
  use BackendWeb, :controller

  def req_top100_callback(conn, %{"oauth_token" => token, "oauth_verifier" => verifier}) do
    config = Application.fetch_env!(:backend, :req_t100_twitter_info)
    ExTwitter.configure(:process, config)
    {:ok, %{oauth_token: access_token, oauth_token_secret: access_token_secret}} = ExTwitter.access_token(verifier, token)

    text(conn, "access_token: #{access_token} access_token_secret: #{access_token_secret}")
  end
end
