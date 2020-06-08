defmodule Backend.PlayerInfo do
  @moduledoc false

  #  @na_players MapSet.new([
  #  "Brimful",
  #  "NoHandsGamer",
  #  "Killinallday",
  #  "Impact",
  #  "Tincho",
  #  "PapaJason",
  #  "Villain",
  #  "Dabs",
  #  "Gle",
  #  "Zeh",
  #  "Innovation",
  #  "TheLastChamp",
  #  "IrvinG",
  #  "Cesky",
  #  "LeandroLeal"
  #  ])
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
end
