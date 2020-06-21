defmodule Backend.Doctest do
  use ExUnit.Case, async: true
  doctest Backend.Blizzard
  doctest BackendWeb.LeaderboardView
  doctest Backend.BattlefyUtil
  doctest Backend.MastersTour.PlayerStats
end
