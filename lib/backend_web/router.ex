defmodule BackendWeb.Router do
  use BackendWeb, :router
  import Phoenix.LiveDashboard.Router
  import Plug.BasicAuth
  alias BackendWeb.LivePlug.AssignDefaults
  alias BackendWeb.LivePlug.AdminAuth
  use ErrorTracker.Web, :router
  use Kaffy.Routes, scope: "/admin/kaffy", pipe_through: [:auth, :kaffy_admin]

  pipeline :auth do
    plug(Backend.UserManager.Pipeline)
  end

  pipeline :kaffy_admin do
    plug(Backend.Plug.AdminAuth, role: :kaffy)
  end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  forward("/api/graphql", Absinthe.Plug, schema: BackendWeb.Schema)

  forward("/graphiql", Absinthe.Plug.GraphiQL,
    schema: BackendWeb.Schema,
    interface: :playground
  )

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:put_root_layout, {BackendWeb.LayoutView, :root})
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  # defp api_auth(conn, _opts) do
  #   with {user, pass} <- Plug.BasicAuth.parse_basic_auth(conn),
  #        {:ok, api_user} <- Backend.Api.verify_user(user, pass) do
  #     assign(conn, :api_user, api_user)
  #   else
  #     _ -> conn |> Plug.BasicAuth.request_basic_auth() |> halt()
  #   end
  # end

  pipeline :admins_only do
    plug(:basic_auth,
      username: "admin",
      password: Application.compile_env!(:backend, :admin_pass)
    )
  end

  scope "/api/public", BackendWeb do
    pipe_through([:api])
    post("/dt/game", DeckTrackerController, :put_game)
    put("/dt/game", DeckTrackerController, :put_game)
    get("/log", PageController, :log)
    post("/log", PageController, :log)
    put("/log", PageController, :log)

    post("/patreon/webhook", PatreonController, :webhook)
  end

  scope "/api", BackendWeb do
    pipe_through([:api])
    post("/deck-info", DeckController, :deck_info)
    get("/deck-info/*deck", DeckController, :deck_info)
    get("/who-am-i", ApiController, :who_am_i)
    post("/dt/game", DeckTrackerController, :put_game)
    put("/dt/game", DeckTrackerController, :put_game)
    get("/cards/dust-free", CardsController, :dust_free)
    get("/cards/all", CardsController, :all)
    get("/cards/collectible", CardsController, :collectible)
    get("/cards/metadata", CardsController, :metadata)
  end

  scope "/", BackendWeb do
    pipe_through([:browser, :auth])

    get("/arcticles/reveal/booms-incredible-inventions-mage", RevealController, :boom)
    get("/hs/article/:blog_id", HearthstoneController, :article)
    get("/battlefy/tournament/020fface81eb7119705c0df5:bla", PageController, :rick_astley)

    get("/leaderboard", LeaderboardController, :index)
    get("/leaderboard/player-stats", LeaderboardController, :player_stats)

    get(
      "/leaderboard/player-history/region/:region/period/:period/leaderboard_id/:leaderboard_id/player/:player",
      LeaderboardController,
      :player_history
    )

    get(
      "/leaderboard/rank-history/region/:region/period/:period/leaderboard_id/:leaderboard_id/rank/:rank",
      LeaderboardController,
      :rank_history
    )

    get(
      "/leaderboard/player-history/region/:region/season_id/:season_id/leaderboard_id/:leaderboard_id/player/:player",
      LeaderboardController,
      :player_history_old
    )

    get("/leaderboard/points", LeaderboardController, :points)

    live("/", FeedLive)
    get("/incubator", PageController, :incubator)
    get("/about", PageController, :about)
    get("/donate-follow", PageController, :donate_follow)
    get("/privacy", PageController, :privacy)

    get("/hdt-plugin", PageController, :hdt_plugin)

    get("/log", PageController, :log)
    put("/log", PageController, :log)
    post("/log", PageController, :log)

    get("/test", PageController, :test)

    get("/hs/patch-notes", HearthstoneController, :patch_notes)
    get("/hs/patchnotes", HearthstoneController, :patch_notes)

    get("/invited/:tour_stop", MastersTourController, :invited_players)
    get("/invited/", MastersTourController, :invited_players)
    get("/qualifiers", MastersTourController, :qualifiers)
    get("/mt/points", MastersTourController, :points)
    get("/mt/earnings", MastersTourController, :earnings)
    get("/mt/qualifier-stats/", MastersTourController, :qualifier_stats)
    get("/mt/qualifier-stats/:tour_stop", MastersTourController, :qualifier_stats)
    get("/mt/tour-stops", MastersTourController, :tour_stops)
    get("/mt/stats", MastersTourController, :masters_tours_stats)
    get("/mtq/:mtq_num", MastersTourController, :qualifier_redirect)
    get("/mtq/:mtq_num/*rest", MastersTourController, :qualifier_redirect)

    get("/hdt-plugin/latest-version", DeckTrackerController, :hdt_plugin_latest_version)
    get("/hdt-plugin/latest", DeckTrackerController, :hdt_plugin_latest_file)
    get("/hdt-plugin/d0nkey.top plugin.dll", DeckTrackerController, :hdt_plugin_latest_file)

    get(
      "/battlefy/third-party-tournaments/stats/:stats_slug",
      BattlefyController,
      :organization_tournament_stats
    )

    get("/battlefy/third-party-tournaments", BattlefyController, :organization_tournaments)

    live("/battlefy/tournament/:tournament_id/match/:match_id", BattlefyMatchLive)
    live("/battlefy/tournament/:tournament_id/lineups", BattlefyTournamentDecksLive)

    get("/profile/battlefy/tournament/:tournament_id", BattlefyController, :profile_tournament)
    get("/battlefy/tournament/:tournament_id", BattlefyController, :tournament)

    get(
      "/battlefy/tournament/:tournament_id/player/:team_name",
      BattlefyController,
      :tournament_player
    )

    get(
      "/battlefy/tournament/:tournament_id/future/:team_name",
      BattlefyController,
      :tournament_player
    )

    get(
      "/battlefy/tournament/:tournament_id/decks/:team_name",
      BattlefyController,
      :tournament_decks
    )

    get(
      "/battlefy/tournaments-stats/",
      BattlefyController,
      :tournaments_stats
    )

    get("/battlefy/user-tournaments/:slug", BattlefyController, :user_tournaments)

    get("/hsreplay/matchups", HSReplayController, :matchups)

    get("/discord/broadcasts", DiscordController, :broadcasts)

    # get "/discord/broadcast", DiscordController, :broadcast
    # post "/discord/broadcast", DiscordController, :broadcast

    get("/discord/broadcasts/:id/publish/:token", DiscordController, :view_publish)
    post("/discord/broadcasts/:id/publish/:token", DiscordController, :publish)

    get("/discord/broadcasts/:id/subscribe/:token", DiscordController, :view_subscribe)
    post("/discord/broadcasts/:id/subscribe/:token", DiscordController, :subscribe)

    get("/discord/create_broadcast", DiscordController, :create_broadcast)

    get("/player-profile/:battletag_full", PlayerController, :player_profile)

    get("/streamer-decks/twitch-login/:twitch_login", StreamingController, :streamers_decks)
    get("/streamer-decks", StreamingController, :streamer_decks)
    get("/streamer-instructions", StreamingController, :streamer_instructions)
    live("/streaming-now", StreamingNowLive)
    live("/youtube/bnet-chat/:video_id", YoutubeChatLive)

    live("/cards", CardsLive)
    live("/card/:card_id", CardLive)

    live("/deckbuilder", DeckBuilderLive)
    live("/deckviewer", DeckviewerLive)

    get("/stats/explanation", StatsController, :explanation)
    live("/card-stats", CardStatsLive)
    live("/meta", MetaLive)
    live("/decks", DecksLive)
    live("/deck-sheets/:sheet_id", DeckSheetViewLive)
    live("/deck-sheets", DeckSheetsIndexLive)
    live("/replays", ReplaysLive)

    live("/archetype/:archetype", ArchetypeLive)

    live("/hcm-2022", HCM2022Live)
    live("/lineup-history/:source/:name", LineupHistoryLive)

    # get "/decks", PageController, :disabled
    live("/deck/*deck", DeckLive)
    live("/deck-tracker/*deck", DeckTrackerLive)

    get("/grandmasters/season/:season", GrandmastersController, :grandmasters_season)

    get("/who-am-i", AuthController, :who_am_i)
    get("/whoami", AuthController, :who_am_i)
    get("/login-welcome", AuthController, :login_welcome)
    get("/logout", AuthController, :logout)
    live("/feed", FeedLive)
    get("/empty/with-nav", EmptyController, :with_nav)
    get("/empty/without-nav", EmptyController, :without_nav)

    live("/fantasy", FantasyIndexLive)
    live("/fantasy/leagues/:league_id/draft", FantasyDraftLive)
    live("/fantasy/leagues/:league_id", FantasyLeagueLive)
    live("/fantasy/leagues/join/:join_code", JoinLeagueLive)

    get("/util/twitter/callback/reqtop100", TwitterController, :req_top100_callback)

    get("/discord-bot", SocialController, :discord_bot)
    get("/discord_bot", SocialController, :discord_bot)
    get("/discord", SocialController, :discord)
    get("/paypal", SocialController, :paypal)
    get("/twitch", SocialController, :twitch)
    get("/patreon", SocialController, :patreon)
    get("/twitter", SocialController, :twitter)
    get("/notion", SocialController, :notion)
    get("/liberapay", SocialController, :liberapay)

    live("/gm/lineups", GrandmastersLineup)
    live("/gm", GrandmastersLive)
    live("/gm/profile/:gm", GrandmasterProfileLive)
    live("/tournament-lineups/:tournament_source/:tournament_id", TournamentLineups)

    live("/wc/2021", WC2021Live)
    live("/wc/2022", WC2022Live)
    live("/wc/2024/china-qualifiers", WC2024ChinaQualifiers)
    live("/seasonal/2022/summer", SummerChamps2022Live)

    live("/max/nations-2022", MaxNations2022Live)
    live("/max/nations-2022/nation/:nation", MaxNations2022NationLive)
    live("/max/nations-2022/player/:player", MaxNations2022PlayerLive)

    live("/my-replays", MyReplaysLive)
    live("/my-decks", MyDecksLive)

    live("/groups/:group_id/decks", GroupDecksLive)
    live("/groups/:group_id/replays", GroupReplaysLive)
    live("/groups/:group_id", GroupLive)
    live("/groups", MyGroupsLive)
    live("/my-groups", MyGroupsLive)

    live("/player/:player_btag/decks", PlayerDecksLive)
    live("/player/:player_btag/replays", PlayerReplaysLive)

    live("/pony-dojo/power-rankings", PonyDojoLive)
    get("/pony-dojo/update-power-rankings", UtilController, :update_pony_dojo)

    get("/wild", FunController, :wild)

    get("/ads.txt", PageController, :ads_txt)

    get("/bla-bla", PageController, :bla_bla)
    get("/always-error", PageController, :always_error)

    live("/lobby-legends", LobbyLegendsLive)
    live("/lineup-submitter/hcm_2022", LineupSubmitterLive)

    live("/twitch/bot", TwitchBotLive)
    live("/twitch/bot/new-command", TwitchNewCommandLive)

    live("/scratchpad", ScratchPadLive)
  end

  scope "/", BackendWeb do
    pipe_through([:browser, :auth, :ensure_auth])
    live("/profile/settings", ProfileSettingsLive)

    live(
      "/tournament-streams/:tournament_source/:tournament_id/manager",
      TournamentStreamManagerLive
    )
  end

  scope "/torch", BackendWeb do
    pipe_through([:browser, :auth])
    get("/battletag_info/batch", BattletagController, :batch)
    post("/battletag_info/batch-insert", BattletagController, :batch_insert)
    resources("/battletag_info", BattletagController)
    resources("/users", UserController)
    resources("/tournament-streams", TournamentStreamController)
    get("/invited_player/batch", InvitedPlayerController, :batch)
    post("/invited_player/batch-insert", InvitedPlayerController, :batch_insert)
    resources("/invited_player", InvitedPlayerController)
    resources("/feed_items", FeedItemController)
    resources("/fantasy-leagues", LeagueController)
    resources("/api-users", ApiUserController)
    resources("/groups", GroupController)
    resources("/group-memberships", GroupMembershipController)
    resources("/old-battletags", OldBattletagController)
    resources("/twitch-commands", TwitchCommandController)
    resources("/periods", PeriodController)
    resources("/ranks", RankController)
    resources("/regions", RegionController)
    resources("/formats", FormatController)
    resources("/patreon-tiers", PatreonTierController)
  end

  scope "/admin", BackendWeb do
    pipe_through([:browser, :admins_only])
    get("/", AdminController, :index)
    get("/get-all-leaderboards", AdminController, :get_all_leaderboards)
    get("/test", AdminController, :test)
    get("/config-vars", AdminController, :config_vars)
    get("/config-vars/backend", AdminController, :config_vars)
    get("/mt-player-nationality/:tour_stop", AdminController, :mt_player_nationality)
    get("/fix-fantasy-mt-btag/:tour_stop", AdminController, :fantasy_fix_btag)
    get("/recalculate_archetypes/:minutes_ago", AdminController, :recalculate_archetypes)
  end

  scope "/", BackendWeb do
    pipe_through([:browser, :auth])
    error_tracker_dashboard("/errors", on_mount: [AssignDefaults, {AdminAuth, :dashboard}])

    live_dashboard("/dashboard",
      metrics: Backend.Telemetry,
      ecto_repos: [Backend.Repo],
      on_mount: [AssignDefaults, {AdminAuth, :dashboard}],
      additional_pages: [
        oban: Oban.LiveDashboard,
        agg_log: BackendWeb.LiveDashboard.AggregationLogPage,
        oban_count: BackendWeb.LiveDashboard.ObanCountPage,
        game_per_min: BackendWeb.LiveDashboard.GamePerMinPage,
        client_addr_conn: BackendWeb.LiveDashboard.ClientAddrConnPage
      ]
    )
  end

  scope "/auth", BackendWeb do
    pipe_through([:browser, :auth])
    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
  end
end
