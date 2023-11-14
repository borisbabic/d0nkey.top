import Config

config :backend, QuantumScheduler,
  jobs: [
    {"37 3 * * *", fn -> Backend.HearthstoneJson.update_cards() end},
    {"37 13 * * *", fn -> Backend.ReqvamTop100Tweeter.check_and_tweet() end},
    {"37 5 * * *", fn -> Backend.PrioritizedBattletagCache.update_cache() end},
    # {"1 * * * *", fn -> Backend.MastersTour.sign_me_up() end},
    {"17 * * * *", fn -> Backend.DeckFeedItemUpdater.update_deck_items() end},
    {"18 * * * *", fn -> Backend.Feed.FeedBag.update() end},
    {"47 * * * *", fn -> Backend.Feed.decay_feed_items() end},
    {"48 * * * *", fn -> Backend.Feed.FeedBag.update() end},
    # {"* * * * *", fn -> Backend.Grandmasters.update() end},
    {"53 * * * *", fn -> Backend.PlayerIconBag.update() end},
    # {"* * * * *", fn -> Backend.Streaming.update_hdt_streamer_decks() end},
    {"57 * * * *", fn -> Backend.MastersTour.refresh_current_invited() end},
    # {"41 * * * *", fn -> Backend.PonyDojo.update() end},
    {"43 * * * *", fn -> Backend.DiscordBot.update_all_guilds(5000) end},
    {"*/3 * * * *", fn -> Backend.Leaderboards.save_current(200) end},
    {"2 * * * *", fn -> Backend.Leaderboards.save_current(3000) end},
    {"43 18 * * *", fn -> Backend.Leaderboards.save_current(nil) end},
    {"31 17 * * *", fn -> Backend.Hearthstone.update_metadata() end},
    {"13 * * * *", fn -> Backend.Hearthstone.CardBag.refresh_table() end},
    {"11 */2 * * *", fn -> Backend.Hearthstone.update_collectible_cards() end},
    {"17 08 * * *", fn -> Backend.Hearthstone.update_all_cards() end},
    # {"*/9 * * * *", fn -> Backend.Leaderboards.refresh_latest() end},
    {"7 * * * *", fn -> Backend.Leaderboards.prune_empty_seasons() end},
    {"11 08 1 * *", fn -> Backend.Leaderboards.copy_last_month_to_lobby_legends() end},
    {"*/53 * * * *", fn -> Backend.Hearthstone.regenerate_false_neutral_deckcodes() end},
    {"*/8 * * * *", fn -> Hearthstone.DeckTracker.ArchetypeBag.update() end},
    # {"3 * * * *", fn -> Hearthstone.DeckTracker.DeckStatsAggregator.enqueue_last_hour() end},
    # {"23 */2 * * *", fn -> Hearthstone.DeckTracker.refresh_agg_stats() end},
    {"*/4 * * * *", fn -> Backend.LatestHSArticles.update() end}
  ]
