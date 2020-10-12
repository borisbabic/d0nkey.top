defmodule BackendWeb.Router do
  use BackendWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :auth do
    plug Backend.UserManager.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {BackendWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  import Plug.BasicAuth

  pipeline :admins_only do
    plug :basic_auth, username: "admin", password: Application.fetch_env!(:backend, :admin_pass)
  end

  scope "/", BackendWeb do
    pipe_through [:browser, :auth]

    get "/leaderboard", LeaderboardController, :index
    get "/leaderboard/player-stats", LeaderboardController, :player_stats

    get "/", PageController, :index
    get "/incubator", PageController, :incubator
    get "/donate-follow", PageController, :donate_follow

    get "/invited/:tour_stop", MastersTourController, :invited_players
    get "/invited/", MastersTourController, :invited_players
    get "/qualifiers", MastersTourController, :qualifiers
    get "/mt/earnings", MastersTourController, :earnings
    get "/mt/qualifier-stats/", MastersTourController, :qualifier_stats
    get "/mt/qualifier-stats/:tour_stop", MastersTourController, :qualifier_stats
    get "/mt/tour-stops", MastersTourController, :tour_stops

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

    get "/grandmasters/season/:season", GrandmastersController, :grandmasters_season

    get "/admin/get-all-leaderboards", AdminController, :get_all_leaderboards
    get "/admin/test", AdminController, :test

    get "who-am-i", AuthController, :who_am_i
  end

  scope "/" do
    pipe_through [:browser, :admins_only]
    live_dashboard "/dashboard", metrics: Backend.Telemetry
  end

  scope "/auth", BackendWeb do
    pipe_through [:browser, :auth]
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end
end
