defmodule BackendWeb.Router do
  use BackendWeb, :router
  import Phoenix.LiveDashboard.Router
  import Plug.BasicAuth
  require Incendium

  pipeline :auth do
    plug Backend.UserManager.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  forward "/api/graphql", Absinthe.Plug, schema: BackendWeb.Schema

  forward "/graphiql", Absinthe.Plug.GraphiQL,
    schema: BackendWeb.Schema,
    interface: :playground

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

  defp api_auth(conn, _opts) do
    with {user, pass} <- Plug.BasicAuth.parse_basic_auth(conn),
         {:ok, api_user} <- Backend.Api.verify_user(user, pass) do
      assign(conn, :api_user, api_user)
    else
      _ -> conn |> Plug.BasicAuth.request_basic_auth() |> halt()
    end
  end

  pipeline :admins_only do
    plug :basic_auth, username: "admin", password: Application.fetch_env!(:backend, :admin_pass)
  end


  scope "/api/public", BackendWeb do
    pipe_through [:api]
    post "/dt/game", DeckTrackerController, :put_game
    put "/dt/game", DeckTrackerController, :put_game
    get "/log", PageController, :log
    post "/log", PageController, :log
    put "/log", PageController, :log
  end

  scope "/api", BackendWeb do
    pipe_through [:api]
    get "/who-am-i", ApiController, :who_am_i
    post "/dt/game", DeckTrackerController, :put_game
    put "/dt/game", DeckTrackerController, :put_game
  end

  scope "/incendium", BackendWeb do
    Incendium.routes(IncendiumController)
  end

  scope "/", BackendWeb do
    pipe_through [:browser, :auth]

    get "/leaderboard", LeaderboardController, :index
    get "/leaderboard/player-stats", LeaderboardController, :player_stats
    get "/leaderboard/player-history/region/:region/period/:period/leaderboard_id/:leaderboard_id/player/:player", LeaderboardController, :player_history
    get "/leaderboard/player-history/region/:region/season_id/:season_id/leaderboard_id/:leaderboard_id/player/:player", LeaderboardController, :player_history_old

    live "/", FeedLive
    get "/incubator", PageController, :incubator
    get "/about", PageController, :about
    get "/donate-follow", PageController, :donate_follow
    get "/privacy", PageController, :privacy

    get "/log", PageController, :log
    put "/log", PageController, :log
    post "/log", PageController, :log

    get "/invited/:tour_stop", MastersTourController, :invited_players
    get "/invited/", MastersTourController, :invited_players
    get "/qualifiers", MastersTourController, :qualifiers
    get "/mt/earnings", MastersTourController, :earnings
    get "/mt/qualifier-stats/", MastersTourController, :qualifier_stats
    get "/mt/qualifier-stats/:tour_stop", MastersTourController, :qualifier_stats
    get "/mt/tour-stops", MastersTourController, :tour_stops
    get "/mt/stats", MastersTourController, :masters_tours_stats
    get "/mtq/:mtq_num", MastersTourController, :qualifier_redirect
    get "/mtq/:mtq_num/*rest", MastersTourController, :qualifier_redirect

    get "/battlefy/third-party-tournaments/stats/:stats_slug",
        BattlefyController,
        :organization_tournament_stats

    get "/battlefy/third-party-tournaments", BattlefyController, :organization_tournaments

    live "/battlefy/tournament/:tournament_id/match/:match_id", BattlefyMatchLive
    live "/battlefy/tournament/:tournament_id/lineups", BattlefyTournamentDecksLive

    get "/profile/battlefy/tournament/:tournament_id", BattlefyController, :profile_tournament
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

    get "/battlefy/tournaments-stats/",
        BattlefyController,
        :tournaments_stats

    get "/battlefy/user-tournaments/:slug", BattlefyController, :user_tournaments

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
    get "/streamer-instructions", StreamingController, :streamer_instructions
    live "/streaming-now", StreamingNowLive
    live "/youtube/bnet-chat/:video_id", YoutubeChatLive
    live "/deckviewer", DeckviewerLive
    live "/decks", DecksLive
    live "/deck/*deck", DeckLive

    get "/grandmasters/season/:season", GrandmastersController, :grandmasters_season

    get "/who-am-i", AuthController, :who_am_i
    get "/whoami", AuthController, :who_am_i
    get "/login-welcome", AuthController, :login_welcome
    get "/logout", AuthController, :logout
    live "/feed", FeedLive
    get "/empty/with-nav", EmptyController, :with_nav
    get "/empty/without-nav", EmptyController, :without_nav

    live "/fantasy", FantasyIndexLive
    live "/fantasy/leagues/:league_id/draft", FantasyDraftLive
    live "/fantasy/leagues/:league_id", FantasyLeagueLive
    live "/fantasy/leagues/join/:join_code", JoinLeagueLive

    get "/util/twitter/callback/reqtop100", TwitterController, :req_top100_callback

    get "/discord", SocialController, :discord
    get "/paypal", SocialController, :paypal
    get "/twitch", SocialController, :twitch
    get "/patreon", SocialController, :patreon
    get "/twitter", SocialController, :twitter
    get "/notion", SocialController, :notion
    get "/liberapay", SocialController, :liberapay

    live "/gm/lineups", GrandmastersLineup
    live "/gm", GrandmastersLive
    live "/gm/profile/:gm", GrandmasterProfileLive
    live "/tournament-lineups/:tournament_source/:tournament_id", TournamentLineups

    live "/wc/2021", WC2021Live

    live "/my-replays", MyReplaysLive
    live "/my-decks", MyDecksLive

    get "/wild", FunController, :wild
  end

  scope "/", BackendWeb do
    pipe_through [:browser, :auth, :ensure_auth]
    live "/profile/settings", ProfileSettingsLive
  end

  scope "/torch", BackendWeb do
    pipe_through [:browser, :auth]
    get "/battletag_info/batch", BattletagController, :batch
    post "/battletag_info/batch-insert", BattletagController, :batch_insert
    resources "/battletag_info", BattletagController
    resources "/users", UserController
    get "/invited_player/batch", InvitedPlayerController, :batch
    post "/invited_player/batch-insert", InvitedPlayerController, :batch_insert
    resources "/invited_player", InvitedPlayerController
    resources "/feed_items", FeedItemController
    resources "/fantasy-leagues", LeagueController
    resources "/api-users", ApiUserController
  end

  scope "/admin", BackendWeb do
    pipe_through [:browser, :admins_only]
    get "/", AdminController, :index
    get "/get-all-leaderboards", AdminController, :get_all_leaderboards
    get "/test", AdminController, :test
    get "/config-vars", AdminController, :config_vars
    get "/config-vars/backend", AdminController, :config_vars
    get "/config-vars/ueberauth", AdminController, :ueberauth_config_vars
    get "/mt-player-nationality/:tour_stop", AdminController, :mt_player_nationality
    get "/fix-fantasy-mt-btag/:tour_stop", AdminController, :fantasy_fix_btag
    get "/recalculate_archetypes/:minutes_ago", AdminController, :recalculate_archetypes
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
