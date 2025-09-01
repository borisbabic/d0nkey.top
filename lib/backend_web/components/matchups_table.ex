defmodule Components.MatchupsTable do
  @moduledoc false
  use BackendWeb, :surface_live_component

  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Matchups
  alias Components.WinrateTag
  alias Matchup

  prop(matchups, :any, required: true)

  def render(assigns) do
    ~F"""
      <div class="table-scrolling-sticky-wrapper">
        <div class="notification is-warning">This UI is WIP (work in progress).</div>
        <table class="tw-text-black tw-border-collapse tw-table-fixed tw-text-center" :if={sorted_matchups = sort_matchups(@matchups)}>
          <thead class="tw-text-black">
            <tr>
            <th rowspan="2" class="tw-w-[10px]">Total Winrate</th>
            <th rowspan="2" class="tw-w-[50px]">Archetype</th>
            <th :for={matchup <- sorted_matchups} class={"tw-w-[300px]", "tw-text-black", "class-background", Deck.extract_class(Matchups.archetype(matchup)) |> String.downcase()}>
              {Matchups.archetype(matchup)}
            </th>
            </tr>
            <tr :if={total_games = total_games(sorted_matchups)}>
              <th :for={matchup <- sorted_matchups} class="tw-text-center tw-border tw-border-gray-600 tw-w-[10px] tw-bg-gray-500"> {Util.percent(Matchups.total_stats(matchup).games, total_games) |> Float.round(1)}%</th>
            </tr>
          </thead>
          <tbody>
            <tr class="tw-text-center tw-h-[25px] tw-truncate tw-text-clip" :for={matchup <- sorted_matchups} >
              <WinrateTag tag_name="td" class={"tw-text-center tw-border tw-border-gray-600 tw-w-[10px]"} :if={%{winrate: winrate, games: games} = Matchups.total_stats(matchup)} winrate={winrate} sample={games} />
              <td class={"tw-border", "tw-border-gray-600", "sticky-column", "class-background", Deck.extract_class(Matchups.archetype(matchup)) |> String.downcase()}>
                {Matchups.archetype(matchup)}
              </td>
              <td data-balloon-pos="up" aria-label={"#{Matchups.archetype(matchup)} versus #{opp} - #{games} games"}:for={{opp, %{winrate: winrate, games: games}} <- Enum.map(sorted_matchups, fn opp -> {Matchups.archetype(opp), Matchups.opponent_stats(matchup, opp)} end)}>
                <WinrateTag winrate={winrate} sample={games} />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    """
  end

  defp total_games(matchups) do
    Enum.sum_by(matchups, fn m ->
      Matchups.total_stats(m)
      |> Map.get(:games, 0)
    end)
  end

  defp sort_matchups(matchups) do
    Enum.sort_by(
      matchups,
      fn m ->
        Matchups.total_stats(m)
        |> Map.get(:games, 0)
      end,
      :desc
    )
  end
end
