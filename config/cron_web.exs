import Config

config :backend, QuantumScheduler,
  jobs: [
    # {"0 12 * * Mon", fn -> Backend.Fantasy.advance_gm_round() end},
    # {"13 * * * *", fn -> Backend.MastersTour.qualifiers_update() end},
    {"37 3 * * *", fn -> Backend.HearthstoneJson.update_cards() end},
    {"37 5 * * *", fn -> Backend.PrioritizedBattletagCache.update_cache() end},
    {"18 * * * *", fn -> Backend.Feed.FeedBag.update() end},
    {"48 * * * *", fn -> Backend.Feed.FeedBag.update() end},
    {"53 * * * *", fn -> Backend.PlayerIconBag.update() end},
    {"* * * * *", fn -> Backend.AdsTxtCache.update() end},
    {"37 18 * * *", fn -> Backend.Hearthstone.update_metadata() end},
    {"13 * * * *", fn -> Backend.Hearthstone.CardBag.refresh_table() end},
    {"* */2 * * *", fn -> Hearthstone.DeckTracker.ArchetypeBag.update() end},
    {"11 */2 * * *", fn -> Backend.Hearthstone.update_collectible_cards() end},
    {"*/4 * * * *", fn -> Backend.LatestHSArticles.update() end}
  ]
