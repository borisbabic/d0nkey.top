defmodule Backend.Doctest do
  use ExUnit.Case, async: true
  doctest Backend.Blizzard
  doctest BackendWeb.LeaderboardView
  doctest Backend.Battlefy
  doctest Backend.BattlefyUtil
  doctest Backend.MastersTour.PlayerStats
  doctest Backend.TournamentStats
  doctest Backend.TournamentStats.TeamStats
end
