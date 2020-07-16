defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BackendWeb do
    pipe_through :browser

    get "/leaderboard", LeaderboardController, :index
    get "/", PageController, :index
    get "/incubator", PageController, :incubator

    get "/invited/:tour_stop", MastersTourController, :invited_players
    get "/qualifiers", MastersTourController, :qualifiers
    get "/mt/earnings", MastersTourController, :earnings
    get "/mt/qualifier-stats/:tour_stop", MastersTourController, :qualifier_stats

    get "/battlefy/third-party-tournaments", BattlefyController, :organization_tournaments

    get "/battlefy/tournament/:tournament_id", BattlefyController, :tournament

    get "/battlefy/tournament/:tournament_id/player/:team_name",
        BattlefyController,
        :tournament_player

    get "/battlefy/tournament/:tournament_id/future/:team_name",
        BattlefyController,
        :tournament_player

    get "/battlefy/tournament/:tournament_id/decks/:team_name",
        BattlefyController,
        :tournament_decks

    get "/hsreplay/live_feed", HSReplayController, :live_feed
    get "/hsreplay/matchups", HSReplayController, :matchups

    get "/discord/broadcasts", DiscordController, :broadcasts

    # get "/discord/broadcast", DiscordController, :broadcast
    # post "/discord/broadcast", DiscordController, :broadcast

    get "/discord/broadcasts/:id/publish/:token", DiscordController, :view_publish
    post "/discord/broadcasts/:id/publish/:token", DiscordController, :publish

    get "/discord/broadcasts/:id/subscribe/:token", DiscordController, :view_subscribe
    post "/discord/broadcasts/:id/subscribe/:token", DiscordController, :subscribe

    get "/discord/create_broadcast", DiscordController, :create_broadcast

    get "/player-profile/:battletag_full", PlayerController, :player_profile

    get "/streamer-decks/twitch-login/:twitch_login", StreamingController, :streamers_decks
    get "/streamer-decks", StreamingController, :streamer_decks
  end

  # Other scopes may use custom stacks.
  # scope "/api", BackendWeb do
  #   pipe_through :api
  # end
end
