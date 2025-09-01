defmodule Components.MatchupsTable do
  @moduledoc false
  use BackendWeb, :surface_live_component

  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Matchups
  alias Components.WinrateTag
  alias Matchup

  prop(matchups, :any, required: true)
  data(favorited, :list, default: [])
  @local_storage_key "matchups_table_favorite"
  @restore_favorites_event "restore_favorites"

  def mount(socket) do
    {:ok,
     push_event(socket, "restore", %{
       key: @local_storage_key,
       event: @restore_favorites_event,
       target: "#matchups_table_wrapper"
     })}
  end

  def render(assigns) do
    ~F"""
      <div class="table-scrolling-sticky-wrapper" id="matchups_table_wrapper" phx-hook="LocalStorage">
        <table class="tw-text-black tw-border-collapse tw-table-auto tw-text-center" :if={sorted_matchups = favorited_and_sorted_matchups(@matchups, @favorited)}>
          <thead class="tw-text-black decklist-headers">
            <tr>
            <th rowspan="2" class="tw-text-gray-300 tw-align-bottom tw-bg-gray-700">Winrate</th>
            <th rowspan="2" class="tw-text-gray-300 tw-align-bottom tw-bg-gray-700">Archetype<span class="tw-float-right">Popularity:</span></th>
            <th :for={matchup <- sorted_matchups} class={"tw-border", "tw-border-gray-600","tw-text-black", "class-background", Deck.extract_class(Matchups.archetype(matchup)) |> String.downcase()}>
              {Matchups.archetype(matchup)}
            </th>
            </tr>
            <tr :if={total_games = total_games(sorted_matchups)}>
              <th :for={matchup <- sorted_matchups} class="tw-text-justify tw-border tw-border-gray-600 tw-text-gray-300 tw-bg-gray-700"> {Util.percent(Matchups.total_stats(matchup).games, total_games) |> Float.round(1)}%</th>
            </tr>
          </thead>
          <tbody>
            <tr class="tw-text-center tw-h-[25px] tw-truncate tw-text-clip" :for={matchup <- sorted_matchups} >
              <WinrateTag tag_name="td" class={"tw-text-center tw-border tw-border-gray-600"} :if={%{winrate: winrate, games: games} = Matchups.total_stats(matchup)} winrate={winrate} sample={games} />
              <td class={"tw-border", "tw-border-gray-600", "sticky-column", "class-background", Deck.extract_class(Matchups.archetype(matchup)) |> String.downcase()}>
                <button :on-click="toggle_favorite" aria-label="favorite" phx-value-archetype={Matchups.archetype(matchup)}>
                  <HeroIcons.star filled={to_string(Matchups.archetype(matchup)) in @favorited}/>
                </button>
                {Matchups.archetype(matchup)}
              </td>
              <WinrateTag tag_name="td" class="tw-border tw-border-gray-600 tw-text-center" winrate={winrate} sample={games} data-balloon-pos="up" aria-label={"#{Matchups.archetype(matchup)} versus #{opp} - #{games} games"}:for={{opp, %{winrate: winrate, games: games}} <- Enum.map(sorted_matchups, fn opp -> {Matchups.archetype(opp), Matchups.opponent_stats(matchup, opp)} end)}/>
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

  def handle_event(@restore_favorites_event, archetypes_raw, socket) do
    archetypes = String.split(archetypes_raw, ",")
    {:noreply, socket |> assign(favorited: archetypes)}
  end

  defp favorited_and_sorted_matchups(matchups, favorited_raw) do
    favorited_norm = Enum.map(favorited_raw, &normalize_archetype/1)

    favorited =
      Enum.flat_map(favorited_norm, fn archetype ->
        Enum.filter(matchups, fn m ->
          norm = normalize_archetype(Matchups.archetype(m))
          norm == archetype
        end)
      end)

    rest =
      Enum.filter(matchups, fn m ->
        norm = normalize_archetype(Matchups.archetype(m))
        norm not in favorited_norm
      end)

    sorted =
      Enum.sort_by(
        rest,
        fn m ->
          Matchups.total_stats(m)
          |> Map.get(:games, 0)
        end,
        :desc
      )

    favorited ++ sorted
  end

  defp normalize_archetype(archetype), do: to_string(archetype)

  def handle_event("toggle_favorite", %{"archetype" => archetype}, socket) do
    old = Map.get(socket.assigns, :favorited, [])

    new =
      if archetype in old do
        old -- [archetype]
      else
        [archetype | old]
      end

    {:noreply,
     socket
     |> assign(favorited: new)
     |> push_event("store", %{key: @local_storage_key, data: Enum.join(new, ",")})}
  end
end
