defmodule BackendWeb.FantasyHelper do
  @moduledoc false
  alias Backend.Hearthstone
  def competition_name(%{competition: c}), do: c |> competition_name()

  def competition_name(full = <<"gm_"::binary, season::bitstring>>) do
    season
    |> Hearthstone.parse_gm_season()
    |> case do
      {:ok, {year, s}} -> "GM #{year} Season #{s}"
      _ -> full
    end
  end

  def competition_name("lobby_legends_" <> num), do: "Lobby Legends #{num}"
  def competition_name("buffs_may_2021"), do: "Buffs May 2021"
  def competition_name("nerfs_may_2021"), do: "Nerfs May 2021"
  def competition_name("murder-at-castle-nathria"), do: "Murder at Castle Nathria"

  def competition_name(competition) when is_atom(competition),
    do: competition |> to_string() |> competition_name()

  def competition_name(n) when is_binary(n), do: n

  def draft_type_name(%{real_time_draft: true}), do: "Exclusive/Real Time"
  def draft_type_name(%{real_time_draft: false}), do: "Non-exclusive/Async"
end
