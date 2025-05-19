import Config

config :backend, QuantumScheduler,
  jobs: [
    # {"0 12 * * Mon", fn -> Backend.Fantasy.advance_gm_round() end},
    # {"13 * * * *", fn -> Backend.MastersTour.qualifiers_update() end},
    {"37 3 * * *", fn -> Backend.HearthstoneJson.update_cards() end},
    {"37 5 * * *", fn -> Backend.PrioritizedBattletagCache.update_cache() end},
    {"53 * * * *", fn -> Backend.PlayerIconBag.update() end},
    {"* * * * *", fn -> Backend.Hearthstone.CardBag.refresh_table() end},
    {"* */2 * * *", fn -> Hearthstone.DeckTracker.ArchetypeBag.update() end},
    {"17 */2 * * *", fn -> Backend.Hearthstone.update_collectible_cards() end},
    {"*/4 * * * *", fn -> Backend.LatestHSArticles.update() end}
  ]

config :backend, Oban,
  repo: Backend.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [
    default: 1
  ]
