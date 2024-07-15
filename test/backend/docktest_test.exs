defmodule Backend.Doctest do
  use Backend.DataCase, async: true
  doctest Backend.Grandmasters.PromotionRanking
  doctest Backend.Hearthstone.Deck
  doctest Backend.Blizzard
  doctest BackendWeb.LeaderboardView
  doctest Backend.Battlefy
  doctest Backend.BattlefyUtil
  doctest Backend.MastersTour.PlayerStats
  doctest Backend.TournamentStats
  doctest Backend.TournamentStats.TeamStats
  doctest Backend.HSDeckViewer
  doctest Backend.Yaytears
  doctest Backend.Streaming
  doctest Backend.Sheets
  doctest Backend.Sheets.DeckSheet
end
