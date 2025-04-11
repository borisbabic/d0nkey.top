defmodule Components.Lineups.ArchetypeStatsTable do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.SurfaceBulma.Table
  alias Components.SurfaceBulma.Table.Column
  alias FunctionComponents.DeckComponents
  alias Backend.Hearthstone.Deck
  alias Backend.Tournaments.ArchetypeStats
  alias Components.WinrateTag

  prop(stats, :map, required: true)
  prop(adjusted_winrate_type, :atom, default: nil)

  def render(assigns) do
    ~F"""
      <div>
      <Table id={"lineups_stats_#{@id}"} data={stats <- stats(@stats)} striped>
        <Column label="Archetype" sort_by={fn %{archetype: a} -> {Deck.extract_class(a), a} end}> <DeckComponents.archetype archetype={stats.archetype} /> </Column>
        <Column label="Total Games" sort_by={fn %{total: total} -> total end}>{stats.total}</Column>
        <Column label="Wins" sort_by={fn %{wins: wins} -> wins end}>{stats.wins}</Column>
        <Column label="Losses" sort_by={fn %{losses: losses} -> losses end}>{stats.losses}</Column>
        <Column label="Winrate" sort_by={fn stats -> ArchetypeStats.winrate(stats) end}><WinrateTag winrate={ArchetypeStats.winrate(stats)}/></Column>
        <Column label="Adjusted Winrate" sort_by={fn stats -> ArchetypeStats.adjusted_winrate(stats, @adjusted_winrate_type) end}><WinrateTag winrate={ArchetypeStats.adjusted_winrate(stats, @adjusted_winrate_type)}/></Column>
        <Column label="Banned" sort_by={fn %{banned: banned} -> banned end}>{stats.banned}</Column>
        <Column label="Not Banned" sort_by={fn %{not_banned: not_banned} -> not_banned end}>{stats.not_banned}</Column>
        <Column label="Banned %" sort_by={fn %{banned: banned, not_banned: not_banned} -> Util.percent(banned, banned + not_banned) end}>{Util.percent(stats.banned, stats.banned + stats.not_banned) |> Float.round(1)}%</Column>
      </Table>
      </div>
    """
  end

  defp stats(stats) when is_list(stats), do: stats

  defp stats(%{} = stats),
    do: Map.values(stats) |> Enum.filter(& &1.archetype) |> Enum.sort_by(& &1.total, :desc)
end
