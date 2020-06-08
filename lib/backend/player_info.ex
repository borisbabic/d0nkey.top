defmodule Backend.PlayerInfo do
  @moduledoc false

  @na_players MapSet.new([
                "brimful",
                "NoHandsGamer",
                "killinallday",
                "Impact",
                "Tincho",
                "PapaJason",
                "Villain",
                "Dabs",
                "Gle",
                "Zeh",
                "Innovation",
                "TheLastChamp",
                "IrvinG",
                "Cesky",
                "LeandroLeal"
              ])
  @eu_players MapSet.new([
                "xBlyzes",
                "AyRoK",
                "totosh",
                "DeadDraw",
                "Furyhunter",
                "Kalàxz",
                "xxCJ42069xx",
                "Zhym",
                "Leta",
                "Turbon1ck",
                "Fenomeno",
                "Pavelingbook",
                "Dreivo",
                "Gaby",
                "Dizdemon",
                "petrovic",
                "Cosmo",
                "Paradox",
                "iNS4NE",
                "Warma",
                "hunterace",
                "Guntofire",
                "Hoej",
                "NikolajHoej",
                "Yogg",
                "Habugabu",
                "Matty"
              ])
  @ap_players MapSet.new([
                "Alan870806",
                "Bankyugi",
                "TIZS",
                "撒旦降臨",
                "로좀",
                "Duelist",
                "Staz",
                "shanOz",
                "Hi3",
                "GivePLZ",
                "hone",
                "LojomHS",
                "WaningMoon"
              ])

  @cn_players MapSet.new([
                "TNCAnswer",
                "Liooon",
                "SNBrox",
                "SNJing",
                "Bourbon",
                "RNGLeaoh",
                "WEYuansu"
              ])
  def relegated_gms() do
    MapSet.new([
      "Kolento",
      "Pavel",
      "hunterace",
      "Purple",
      "PNC",
      "PapaJason",
      "SamuelTsao",
      "Staz",
      "FroStee"
    ])
  end

  def current_gms() do
    relegated = relegated_gms()

    Backend.MastersTour.list_invited_players(:Jönköping)
    |> Enum.filter(fn %{reason: r} -> String.contains?(r, "Grandmaster") end)
    |> Enum.map(fn %{battletag_full: bf} ->
      Backend.MastersTour.InvitedPlayer.shorten_battletag(bf)
    end)
    |> Enum.filter(fn n -> !MapSet.member?(relegated, n) end)
  end

  def get_region(player) do
    cond do
      MapSet.member?(@na_players, player) -> "NA"
      MapSet.member?(@eu_players, player) -> "EU"
      MapSet.member?(@ap_players, player) -> "AP"
      MapSet.member?(@cn_players, player) -> "CN"
      true -> nil
    end
  end
end
