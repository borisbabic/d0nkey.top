defmodule Components.MatchupsTable do
  @moduledoc false
  use BackendWeb, :surface_live_component

  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Matchups
  alias Components.WinrateTag
  alias Matchup
  import Components.CardStatsTable, only: [sort_direction: 2, sort_direction: 3]

  prop(matchups, :any, required: true)
  prop(min_matchup_sample, :integer, default: 1)
  prop(min_archetype_sample, :integer, default: 1)
  prop(weight_merging_map, :map, default: %{})
  prop(win_loss, :boolean, default: false)
  data(custom_matchup_weights, :map, default: %{})
  data(merged_custom_matchup_weights, :map, default: %{})
  data(headers_by_opponent, :boolean, default: false)
  data(show_popularity, :boolean, default: true)
  data(favorited, :list, default: [])
  data(sort, :map, default: %{sort_by: "games", sort_direction: "desc"})
  @local_storage_key "matchups_table_favorite"
  @local_storage_sort_by_key "matchups_table_sort"
  @local_storage_custom_weights_key "matchups_table_custom_weights"
  @restore_favorites_event "restore_favorites"

  defmacro is_valid_sort(sort) do
    quote do
      is_binary(unquote(sort)) and
        (binary_part(unquote(sort), 0, 9) == "opponent_" or
           unquote(sort) in ["games", "archetype", "winrate"])
    end
  end

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
     })
     |> push_event("restore", %{
       key: @local_storage_custom_weights_key,
       event: "set_custom_weights",
       target: "#matchups_table_wrapper"
     })}
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do
    assigns =
      assigns
      |> assign(
        merged_custom_matchup_weights:
          merge_custom_matchup_weights(assigns.custom_matchup_weights, assigns.weight_merging_map)
      )

    ~F"""
      <div class="table-scrolling-sticky-wrapper" id="matchups_table_wrapper" phx-hook="LocalStorage">
        <table class="tw-text-black tw-border-collapse tw-table-auto tw-text-center" :if={{sorted_matchups, sorted_headers, total_games} = favorited_and_sorted_matchups(@matchups, @favorited, @sort, @min_archetype_sample, @min_matchup_sample, @merged_custom_matchup_weights, @headers_by_opponent)}>
          <thead class="decklist-headers">
            <tr>
            <th rowspan="3" class="tw-text-gray-300 tw-align-bottom tw-bg-gray-700">
              <button :on-click="change_sort" phx-value-sort_by="winrate" phx-value-sort_direction={sort_direction(@sort, "winrate")}>Winrate</button></th>
            <th rowspan="3" class="tw-text-gray-300 tw-align-bottom tw-bg-gray-700">
              <div>
                <button class="tw-float-left" :if={@show_popularity} :on-click="seed_weights" phx-value-total_games={total_games}>Seed Weights</button>
                <button class="tw-float-right" :on-click="reset_weights">Reset Weights</button>
                <br>
                <button :if={@show_popularity} :on-click="change_sort" phx-value-sort_by="games" class="tw-float-right" phx-value-sort_direction={sort_direction(@sort, "games")}>
                Popularity:</button>
              </div>
              <button :on-click="change_sort" phx-value-sort_by="archetype" class="" phx-value-sort_direction={sort_direction(@sort, "archetype", "asc")}>Archetype</button>
            </th>
            <th :for={archetype <- sorted_headers} class={"tw-border", "tw-border-gray-600","tw-text-black", "class-background", Deck.extract_class(archetype) |> String.downcase()}>
              <button :on-click="change_sort" phx-value-sort_by={"opponent_#{archetype}"} phx-value-sort_direction={sort_direction(@sort, "opponent_#{archetype}", "desc")}> {archetype}</button>
            </th>
            </tr>
            <tr >
              <.form for={%{}} id="custom_mathchup_popularity" phx-change="update_custom_matchup_weights" phx-target={@myself}>
                <th :for={archetype <- sorted_headers} class="tw-text-justify tw-border tw-border-gray-600 tw-text-gray-300 tw-bg-gray-700">
                  <input :if={archetype = archetype} class="tw-h-5 has-text-black" type="number" name={archetype} min="0" value={Map.get(@merged_custom_matchup_weights, to_string(archetype))} />
                </th>
              </.form>
            </tr>
            <tr >
              <th :if={@show_popularity} :for={matchup <- sorted_matchups} class="tw-text-justify tw-border tw-border-gray-600 tw-text-gray-300 tw-bg-gray-700"> {Util.percent(Matchups.total_stats(matchup).games, total_games) |> Float.round(1)}%</th>
            </tr>
          </thead>
          <tbody>
            <tr class="tw-h-[30px] tw-text-center tw-truncate tw-text-clip" :for={matchup <- sorted_matchups} >
              <td class=" tw-border tw-border-gray-600 tw-h-[30px]" data-balloon-pos="right" aria-label={"#{Matchups.archetype(matchup)} - #{games} games"} :if={%{winrate: winrate, games: games} = Matchups.total_stats(matchup)} >
                <WinrateTag show_winrate={!@win_loss} win_loss={@win_loss} tag_name="div" class="tw-h-full" winrate={winrate} sample={games} />
              </td>
              <td class={"tw-min-w-[180px]", "tw-border", "tw-border-gray-600", "sticky-column", "class-background", Deck.extract_class(Matchups.archetype(matchup)) |> String.downcase()}>
                <button :on-click="toggle_favorite" aria-label="favorite" phx-value-archetype={Matchups.archetype(matchup)}>
                  <HeroIcons.star filled={to_string(Matchups.archetype(matchup)) in @favorited}/>
                </button>
                {Matchups.archetype(matchup)}
              </td>
              <td class={" tw-border tw-border-gray-600 tw-h-[30px] #{custom_matchup_weights_class(@merged_custom_matchup_weights, opp)}"} data-balloon-pos="up" aria-label={"#{Matchups.archetype(matchup)} versus #{opp} - #{games} games"} :for={{opp, %{winrate: winrate, games: games}} <- Enum.map(sorted_headers, fn opp -> {opp, Matchups.opponent_stats(matchup, opp)} end)}>
              <WinrateTag show_winrate={!@win_loss} win_loss={@win_loss} tag_name="div" class="tw-h-full" winrate={winrate} min_sample={@min_matchup_sample} sample={games} />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    """
  end

  def store_weights(socket, weights) do
    socket
    |> push_event("store", %{key: @local_storage_custom_weights_key, data: Jason.encode!(weights)})
  end

  defp merge_custom_matchup_weights(base_weights, archetype_merge_map)
       when is_map(archetype_merge_map) and map_size(archetype_merge_map) > 0 do
    Enum.group_by(base_weights, fn {key, _value} ->
      Map.get(archetype_merge_map, key, key)
    end)
    |> Map.new(fn {key, weights} ->
      {key, Enum.sum_by(weights, fn {_, value} -> value end)}
    end)
  end

  defp merge_custom_matchup_weights(weights, _custom_matchup_weights) do
    weights
  end

  defp set_custom_matchup_weights(matchups, custom_matchup_weights)
       when map_size(custom_matchup_weights) > 0 do
    Enum.map(matchups, fn m ->
      %{total_stats: total_stats(m, custom_matchup_weights), matchups: m}
    end)
  end

  defp set_custom_matchup_weights(matchups, _custom_matchup_weights) do
    matchups
  end

  defp total_stats(matchup, weights) do
    total = Matchups.total_stats(matchup)

    if weights == nil or weights == %{} do
      total
    else
      {total_winrate_factor, total_weight} =
        Enum.reduce(weights, {0, 0}, fn {archetype, weight}, {winrate_factor, acc_weight} ->
          case Matchups.opponent_stats(matchup, String.to_existing_atom(archetype)) do
            %{winrate: winrate, games: games} when games > 0 and is_number(winrate) ->
              winrate_factor = winrate_factor + winrate * weight
              acc_weight = acc_weight + weight

              {winrate_factor, acc_weight}

            _ ->
              {winrate_factor, acc_weight}
          end
        end)

      %{
        winrate: Util.safe_div(total_winrate_factor, total_weight),
        games: total.games
      }
    end
  end

  defp custom_matchup_weights_class(custom_matchup_weights, archetype) do
    with true <- is_map(custom_matchup_weights),
         false <- custom_matchup_weights == %{},
         w when w in [nil, 0] <- Map.get(custom_matchup_weights, to_string(archetype)) do
      # custom matchups used and opponent not present
      "tw-opacity-50"
    else
      _ -> ""
    end
  end

  defp total_games(matchups) do
    Enum.sum_by(matchups, fn m ->
      Matchups.total_stats(m)
      |> Map.get(:games, 0)
    end)
  end

  defp weights_from_popularity(matchups, total_games) do
    Enum.reduce(matchups, %{}, fn m, acc ->
      games = Matchups.total_stats(m) |> Map.get(:games, 0)
      new_weight = Util.percent(games, total_games) |> Kernel.*(10) |> Float.round(0) |> trunc()
      Map.put(acc, Matchups.archetype(m) |> to_string(), new_weight)
    end)
  end

  def handle_event("seed_weights", %{"total_games" => total_games}, socket) do
    case Integer.parse(total_games) do
      {total_games, _} when is_integer(total_games) ->
        custom_weights = weights_from_popularity(socket.assigns.matchups, total_games)

        {:noreply,
         socket
         |> assign(custom_matchup_weights: custom_weights)
         |> store_weights(custom_weights)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("reset_weights", _, socket) do
    {:noreply,
     socket
     |> assign(custom_matchup_weights: %{})
     |> push_event("clear", %{key: @local_storage_custom_weights_key})}
  end

  def handle_event("update_custom_matchup_weights", args, socket) do
    custom =
      Enum.reduce(args, %{}, fn
        {archetype, popularity}, acc
        when is_binary(popularity) or (is_integer(popularity) and popularity != "") ->
          case Integer.parse(popularity) do
            {val, _} when is_integer(val) ->
              Map.put(acc, archetype, val)

            _ ->
              acc
          end

        _, acc ->
          acc
      end)

    {:noreply,
     socket
     |> assign(custom_matchup_weights: custom)
     |> store_weights(custom)}
  end

  def handle_event("set_custom_weights", custom_weights, socket) do
    with true <- is_binary(custom_weights),
         {:ok, custom} <- Jason.decode(custom_weights) do
      {:noreply, socket |> assign(custom_matchup_weights: custom)}
    else
      _ -> {:noreply, socket}
    end
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
        old ++ [archetype]
      end

    {:noreply,
     socket
     |> assign(favorited: new)
     |> push_event("store", %{key: @local_storage_key, data: Enum.join(new, ",")})}
  end

  def handle_event("set_sort", sort_and_direction, socket) do
    {sort, direction} =
      case String.split(sort_and_direction || "games,desc") do
        [sort, direction | _]
        when is_valid_sort(sort) and direction in ["asc", "desc", :asc, :desc] ->
          {sort, direction}

        [sort] when is_valid_sort(sort) ->
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

  defp favorited_and_sorted_matchups(
         raw_matchups,
         favorited_raw,
         sort,
         min_archetype_sample,
         min_matchup_sample,
         custom_matchup_weights,
         headers_by_opponent
       ) do
    sort_by = Map.get(sort, "sort_by", "games")
    direction_raw = Map.get(sort, "sort_direction", "desc")
    matchups = raw_matchups |> set_custom_matchup_weights(custom_matchup_weights)
    mapper = sort_mapper(sort_by, min_matchup_sample)
    direction = direction(direction_raw)
    favorited_norm = Enum.map(favorited_raw, &normalize_archetype/1)

    favorited =
      Enum.flat_map(favorited_norm, fn archetype ->
        Enum.filter(matchups, fn m ->
          norm = normalize_archetype(Matchups.archetype(m))
          norm == archetype
        end)
      end)

    total = total_games(matchups)

    rest =
      Enum.filter(matchups, fn m ->
        norm = normalize_archetype(Matchups.archetype(m))
        sample = Matchups.total_stats(m) |> Map.get(:games, 0)
        norm not in favorited_norm and sample >= min_archetype_sample
      end)

    sorted = Enum.sort_by(rest, mapper, direction)

    sorted_headers =
      if headers_by_opponent do
        Enum.flat_map(matchups, &Matchups.all_opponents/1)
        |> Enum.uniq()
        |> Enum.sort_by(&archetype_sort_key/1)
      else
        sorted |> Enum.map(&Matchups.archetype/1)
      end

    {favorited ++ sorted, sorted_headers, total}
  end

  defp sort_mapper("games", _) do
    fn m ->
      Matchups.total_stats(m)
      |> Map.get(:games, 0)
    end
  end

  defp sort_mapper("winrate", _) do
    fn m ->
      Matchups.total_stats(m)
      |> Map.get(:winrate, 0)
    end
  end

  defp sort_mapper("opponent_" <> opponent_archetype, min_matchup_sample) do
    fn m ->
      opponent = String.to_existing_atom(opponent_archetype)
      %{winrate: winrate, games: games} = Matchups.opponent_stats(m, opponent)

      if games >= min_matchup_sample do
        winrate
      else
        winrate / 100
      end
    end
  end

  defp sort_mapper("archetype", _) do
    fn m ->
      archetype = Matchups.archetype(m)
      archetype_sort_key(archetype)
    end
  end

  defp archetype_sort_key(archetype) do
    class = Backend.Hearthstone.Deck.extract_class(archetype)
    "#{class}#{archetype}"
  end

  defp normalize_archetype(archetype), do: to_string(archetype)

  defp direction(:desc), do: :desc
  defp direction(:asc), do: :asc
  defp direction("desc"), do: :desc
  defp direction("asc"), do: :asc
  defp direction(_), do: nil
end
