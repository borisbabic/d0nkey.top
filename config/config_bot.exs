import Config

config :backend, QuantumScheduler,
  jobs: [
    {"37 3 * * *", fn -> Backend.HearthstoneJson.update_cards() end},
    {"37 13 * * *", fn -> Backend.ReqvamTop100Tweeter.check_and_tweet() end},
    {"37 5 * * *", fn -> Backend.PrioritizedBattletagCache.update_cache() end},
    # {"1 * * * *", fn -> Backend.MastersTour.sign_me_up() end},
    {"17 * * * *", fn -> Backend.DeckFeedItemUpdater.update_deck_items() end},
    {"17 * * * *", fn -> Backend.DeckFeedItemUpdater.update_deck_items() end},
    {"47 * * * *", fn -> Backend.Feed.decay_feed_items() end},
    {"3 * * * *", &Hearthstone.DeckTracker.aggregate_next_hour/0},
    # Again if something happened with the first, it'll just fail if it already successfully aggregated
    {"13 * * * *", &Hearthstone.DeckTracker.aggregate_next_hour/0},
    {"47 * * * *", &Hearthstone.DeckTracker.aggregate_next_hour/0},
    {"21 1 * * *", &Hearthstone.DeckTracker.aggregate_next_day/0},
    # Again if something happened with the first, it'll just fail if it already successfully aggregated
    {"21 9 * * *", &Hearthstone.DeckTracker.aggregate_next_day/0},
    {"21 17 * * *", &Hearthstone.DeckTracker.aggregate_next_day/0},
    # {"* * * * *", fn -> Backend.Grandmasters.update() end},
    {"53 * * * *", fn -> Backend.PlayerIconBag.update() end},
    # {"* * * * *", fn -> Backend.Streaming.update_hdt_streamer_decks() end},
    {"57 * * * *", fn -> Backend.MastersTour.refresh_current_invited() end},

    # {"41 * * * *", fn -> Backend.PonyDojo.update() end},
    {"43 * * * *", fn -> Backend.DiscordBot.update_all_guilds(5000) end},
    {"*/2 * * * *",
     fn ->
       Backend.Leaderboards.save_current_with_delay([:CN], [:STD, :WLD, :twist], 100, 10_000, 100)
     end},
    {"*/10 * * * *",
     fn ->
       Backend.Leaderboards.save_current_with_delay(
         [:CN],
         [:arena, :BG, :DUO],
         500,
         10_000,
         100
       )
     end},
    {"*/3 * * * *",
     fn ->
       Backend.Leaderboards.save_current_with_delay(
         [:EU, :US, :AP],
         [:STD, :WLD, :twist],
         400,
         10_000,
         1000
       )
     end},
    {"*/10 * * * *",
     fn ->
       Backend.Leaderboards.save_current_with_delay(
         [:EU, :US, :AP],
         [:BG, :DUO],
         1000,
         30_000,
         1000
       )
     end},
    {"*/30 * * * *",
     fn ->
       Backend.Leaderboards.save_current_with_delay(
         [:EU, :US, :AP],
         [:arena],
         1000,
         30_000,
         1000
       )
     end},
    {"3 * * * *",
     fn ->
       Backend.Leaderboards.save_current_with_delay(
         [:EU, :US, :AP],
         [:STD, :WLD, :twist],
         500,
         50_000,
         4000,
         1000
       )
     end},
    {"31 */3 * * *",
     fn ->
       Backend.Leaderboards.save_current_with_delay(
         [:EU, :US, :AP],
         [:STD, :WLD, :twist],
         500,
         50_000,
         5000,
         5000
       )
     end},
    {"11 */2 * * *",
     fn ->
       Backend.Leaderboards.save_current_with_delay(
         [:EU, :US, :AP],
         [:BG, :DUO],
         2000,
         50_000,
         4000,
         1000
       )
     end},
    {"23 */5 * * *",
     fn ->
       Backend.Leaderboards.save_current_with_delay(
         [:EU, :US, :AP],
         [:BG, :DUO],
         2000,
         50_000,
         5000,
         5000
       )
     end},
    {"11 */5 * * *",
     fn ->
       Backend.Leaderboards.save_current_with_delay(
         [:EU, :US, :AP],
         [:arena],
         5000,
         60_000,
         9000,
         1000
       )
     end},
    {"47 * * * *",
     fn ->
       Backend.Leaderboards.save_all_right_after_midnight(
         [:STD, :BG, :WLD, :twist, :DUO, :arena],
         10_000,
         120_000,
         10_001
       )
     end},
    {"37 09 1 * *",
     fn ->
       Backend.Leaderboards.save_last_month_constructed(
         [:STD, :WLD, :twist],
         60_000,
         360_000
       )
     end},
    {"7 * * * *", fn -> Backend.Leaderboards.prune_empty_seasons() end},
    {"11 08 1 * *", fn -> Backend.Leaderboards.copy_last_month_to_lobby_legends() end},
    {"31 17 * * *", fn -> Backend.Hearthstone.update_metadata() end},
    {"* * * * *", fn -> Backend.Hearthstone.CardBag.refresh_table() end},
    {"*/15 * * * *", fn -> Backend.Hearthstone.CardUpdater.enqueue_latest_set() end},
    {"11 */2 * * *", fn -> Backend.Hearthstone.CardUpdater.enqueue_collectible(100) end},
    {"17 07 * * *", fn -> Backend.Hearthstone.CardUpdater.enqueue_all(1000) end},
    # {"*/9 * * * *", fn -> Backend.Leaderboards.refresh_latest() end},
    {"*/53 * * * *", fn -> Backend.Hearthstone.regenerate_false_neutral_deckcodes() end},
    {"* */2 * * *", fn -> Hearthstone.DeckTracker.ArchetypeBag.update() end},
    # {"* * * * *", fn -> Hearthstone.DeckTracker.refresh_agg_stats() end},
    {"* * * * *", fn -> Backend.Patreon.add_new_tiers() end},
    {"13 * * * *", fn -> Backend.UserManager.update_patreon_tiers() end},
    {"*/4 * * * *", fn -> Backend.LatestHSArticles.update() end}
  ]

max_queue_size =
  with raw when is_binary(raw) <- System.get_env("POOL_SIZE"),
       {int, _} when is_integer(int) <- Integer.parse(raw) do
    int
  else
    _ -> 10
  end

queues =
  [
    default: Enum.max([2, div(max_queue_size, 2)]),
    battlefy_lineups: Enum.max([4, max_queue_size - 1]),
    grandmasters_lineups: 1,
    gm_stream_live: 1,
    hsreplay_deck_mapper: 1,
    leaderboards_pages_fetching: 1,
    hs_game_inserter: 15,
    official_api_card_updater: 1,
    deck_deduplicator: 1,
    hsreplay_streamer_deck_inserter: 1
  ]
  |> Enum.map(fn {queue, size} -> {queue, Enum.min([size, max_queue_size])} end)

config :backend, Oban,
  repo: Backend.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: queues

config :backend,
  twitch_bot_chats: ["d0nkeyhs", "d0nkeytop", "titosantanahs"],
  enable_twitch_bot: true
