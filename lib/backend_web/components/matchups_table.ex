defmodule Components.MatchupsTable do
  @moduledoc false
  use BackendWeb, :surface_live_component

  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Matchups
  alias Components.WinrateTag
  alias Matchup
  import Components.CardStatsTable, only: [sort_direction: 2, sort_direction: 3]

  prop(matchups, :any, required: true)
  prop(min_sample, :integer, default: 1)
  data(favorited, :list, default: [])
  data(sort, :map, default: %{sort_by: "games", sort_direction: "desc"})
  @local_storage_key "matchups_table_favorite"
  @local_storage_sort_by_key "matchups_table_sort"
  @restore_favorites_event "restore_favorites"

  def mount(socket) do
    {:ok,
     socket
     |> push_event("restore", %{
       key: @local_storage_key,
       event: @restore_favorites_event,
       target: "#matchups_table_wrapper"
     })
     |> push_event("restore", %{
       key: @local_storage_sort_by_key,
       event: "set_sort",
       target: "#matchups_table_wrapper"
     })}
  end

  def render(assigns) do
    ~F"""
      <div class="table-scrolling-sticky-wrapper" id="matchups_table_wrapper" phx-hook="LocalStorage">
        <table class="tw-text-black tw-border-collapse tw-table-auto tw-text-center" :if={sorted_matchups = favorited_and_sorted_matchups(@matchups, @favorited, @sort)}>
          <thead class="tw-text-black decklist-headers">
            <tr>
            <th rowspan="2" class="tw-text-gray-300 tw-align-bottom tw-bg-gray-700">
              <button :on-click="change_sort" phx-value-sort_by="winrate" phx-value-sort_direction={sort_direction(@sort, "winrate")}>Winrate</button></th>
            <th rowspan="2" class="tw-text-gray-300 tw-align-bottom tw-bg-gray-700">
              <button :on-click="change_sort" phx-value-sort_by="archetype" phx-value-sort_direction={sort_direction(@sort, "archetype", "asc")}>Archetype</button>
              <button :on-click="change_sort" phx-value-sort_by="games" class="tw-float-right" phx-value-sort_direction={sort_direction(@sort, "games")}>Popularity:</button>
            </th>
            <th :for={matchup <- sorted_matchups} class={"tw-border", "tw-border-gray-600","tw-text-black", "class-background", Deck.extract_class(Matchups.archetype(matchup)) |> String.downcase()}>
              {Matchups.archetype(matchup)}
            </th>
            </tr>
            <tr :if={total_games = total_games(sorted_matchups)}>
              <th :for={matchup <- sorted_matchups} class="tw-text-justify tw-border tw-border-gray-600 tw-text-gray-300 tw-bg-gray-700"> {Util.percent(Matchups.total_stats(matchup).games, total_games) |> Float.round(1)}%</th>
            </tr>
          </thead>
          <tbody>
            <tr class="tw-h-[1px] tw-text-center tw-truncate tw-text-clip" :for={matchup <- sorted_matchups} >
              <td class=" tw-border tw-border-gray-600 tw-h-full" data-balloon-pos="right" aria-label={"#{Matchups.archetype(matchup)} - #{games} games"} :if={%{winrate: winrate, games: games} = Matchups.total_stats(matchup)} winrate={winrate} sample={games} >
                <WinrateTag tag_name="div" class="tw-h-full" winrate={winrate} sample={games} />
              </td>
              <td class={"tw-border", "tw-border-gray-600", "sticky-column", "class-background", Deck.extract_class(Matchups.archetype(matchup)) |> String.downcase()}>
                <button :on-click="toggle_favorite" aria-label="favorite" phx-value-archetype={Matchups.archetype(matchup)}>
                  <HeroIcons.star filled={to_string(Matchups.archetype(matchup)) in @favorited}/>
                </button>
                {Matchups.archetype(matchup)}
              </td>
              <td class=" tw-border tw-border-gray-600 tw-h-full" data-balloon-pos="up" aria-label={"#{Matchups.archetype(matchup)} versus #{opp} - #{games} games"} :for={{opp, %{winrate: winrate, games: games}} <- Enum.map(sorted_matchups, fn opp -> {Matchups.archetype(opp), Matchups.opponent_stats(matchup, opp)} end)}>
              <WinrateTag tag_name="div" class="tw-h-full" winrate={winrate} min_sample={@min_sample} sample={games} />
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

  def handle_event(@restore_favorites_event, archetypes_raw, socket) do
    archetypes = String.split(archetypes_raw || "", ",")
    {:noreply, socket |> assign(favorited: archetypes)}
  end

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

  @valid_sorts ["games", "archetype", "winrate"]

  def handle_event("set_sort", sort_and_direction, socket) do
    {sort, direction} =
      case String.split(sort_and_direction || "games,desc") do
        [sort, direction | _]
        when sort in @valid_sorts and direction in ["asc", "desc", :asc, :desc] ->
          {sort, direction}

        [sort] when sort in @valid_sorts ->
          {sort, "desc"}

        _ ->
          {"games", "desc"}
      end

    {:noreply, socket |> assign(sort: %{"sort_by" => sort, "sort_direction" => direction})}
  end

  def handle_event("change_sort", %{"sort_by" => sort, "sort_direction" => direction}, socket) do
    {:noreply,
     socket
     |> assign(sort: %{"sort_by" => sort, "sort_direction" => direction})
     |> push_event("store", %{key: @local_storage_sort_by_key, data: "#{sort},#{direction}"})}
  end

  defp favorited_and_sorted_matchups(matchups, favorited_raw, sort) do
    sort_by = Map.get(sort, "sort_by", "games")
    direction_raw = Map.get(sort, "sort_direction", "desc")
    mapper = sort_mapper(sort_by)
    direction = direction(direction_raw)
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

    sorted = Enum.sort_by(rest, mapper, direction)

    favorited ++ sorted
  end

  defp sort_mapper("games") do
    fn m ->
      Matchups.total_stats(m)
      |> Map.get(:games, 0)
    end
  end

  defp sort_mapper("winrate") do
    fn m ->
      Matchups.total_stats(m)
      |> Map.get(:winrate, 0)
    end
  end

  defp sort_mapper("archetype") do
    fn m ->
      archetype = Matchups.archetype(m)
      class = Backend.Hearthstone.Deck.extract_class(archetype)
      "#{class}#{archetype}"
    end
  end

  defp normalize_archetype(archetype), do: to_string(archetype)

  defp direction(:desc), do: :desc
  defp direction(:asc), do: :asc
  defp direction("desc"), do: :desc
  defp direction("asc"), do: :asc
  defp direction(_), do: nil
end
