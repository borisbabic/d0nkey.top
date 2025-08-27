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
      <div class="tw-overflow-scroll">
        <div class="notification is-warning">This is WIP (work in progress)</div>
        <table class="tw-text-black tw-border-collapse tw-table tw-text-center " :if={sorted_matchups = sort_matchups(@matchups)}>
          <thead class="tw-sticky tw-top-0 tw-text-black">
            <th class="tw-w-[10px]">Total Winrate</th>
            <th class="tw-w-[10px]">Popularity</th>
            <th class="tw-w-[50px]">Archetype</th>
            <th :for={matchup <- sorted_matchups} class={"decklist-info", Deck.extract_class(Matchups.archetype(matchup)) |> String.downcase()}>
              {Matchups.archetype(matchup)}
            </th>
          </thead>
          <tbody>
            <tr class="tw-text-center tw-h-[25px] tw-truncate tw-text-clip" :for={matchup <- sorted_matchups} :if={total_games = total_games(sorted_matchups)}>
              <WinrateTag tag_name="td" class={"tw-text-center tw-border tw-border-gray-600 tw-w-[10px]"} :if={%{winrate: winrate, games: games} = Matchups.total_stats(matchup)} winrate={winrate} sample={games} />
              <td class="tw-text-center tw-border tw-border-gray-600 tw-w-[10px] tw-bg-gray-500"> {Util.percent(Matchups.total_stats(matchup).games, total_games) |> Float.round(1)}</td>
              <td class={"tw-w-[50px]", "tw-border", "tw-border-gray-600", "tw-sticky", "tw-left-0", "decklist-info", Deck.extract_class(Matchups.archetype(matchup)) |> String.downcase()}>
                {Matchups.archetype(matchup)}
              </td>
              <WinrateTag class="tw-text-center tw-border tw-bg-gray-700 tw-border-gray-600" tag_name="td" :for={%{winrate: winrate, games: games} <- Enum.map(sorted_matchups, fn opp -> Matchups.opponent_stats(matchup, opp) end)} winrate={winrate} sample={games} />
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
