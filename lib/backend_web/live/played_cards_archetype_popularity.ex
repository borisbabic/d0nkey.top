defmodule BackendWeb.PlayedCardsArchetypePopularity do
  @moduledoc "Internal helper for archetyping based on played cards"
  use BackendWeb, :surface_live_view
  import Components.CardStatsTable, only: [add_arrow: 3, add_arrow: 4]
  alias Backend.UserManager.User
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.FormatDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.ClassDropdown
  alias Components.Filter.PlayableCardSelect
  alias Components.LivePatchDropdown
  alias Components.DecklistCard

  @default_min_played_count 100
  @default_sort_by "total"
  data(user, :any)
  data(needs_class?, :boolean, default: false)
  data(can_access?, :boolean, default: false)
  data(card_popularity, :any)
  data(params, :map, default: %{})
  data(criteria, :map, default: %{})
  data(sort_by, :string, default: @default_sort_by)
  data(min_played_count, :integer, default: @default_min_played_count)

  def mount(_params, session, socket) do
    {:ok, socket |> assign_defaults(session) |> put_user_in_context() |> assign_can_access()}
  end

  def render(%{can_access?: false} = assigns) do
    ~F"""
      <div class="title is-2">UNAUTHORIZED</div>
      <div class="title is-3">Internal page. If you're really curious you can become a rare supporter since to access<Components.Socials.patreon link="/patreon" /></div>
      <br>
      <div>
        This page is intended for internal use for helping with archetyping based on played cards. It's unoptimized and taxing the servers. I allow premium supporters to access if they're curious because they have access to other taxing stuff on the site.
      </div>
    """
  end

  def render(assigns) do
    ~F"""
      <div class="title is-2">Played Cards Archetype Popularity</div>
      <PeriodDropdown id="period_dropdown" filter_context={:personal} aggregated_only={false} />
      <FormatDropdown id="format_dropdown" filter_context={:personal} aggregated_only={false} />
      <RankDropdown id="rank_dropdown" filter_context={:personal} aggregated_only={false} />
      <ClassDropdown id="class_dropdown" param="player_class"/>
      <LivePatchDropdown
        id="min_played_count"
        options={[1, 69, 100, 420, 666, 1000, 2000, 3500, 5000, 7000, 9001, 15000, 20000]}
        title={"Min Played Count"}
        param={"min_played_count"}
        selected_as_title={false}
        normalizer={&to_string/1} />
      <PlayableCardSelect id={"player_deck_includes"} format={@params["format"]} param={"player_deck_includes"} selected={@params["player_deck_includes"] || []} title="Include cards"/>
      <PlayableCardSelect id={"player_deck_excludes"} format={@params["format"]} param={"player_deck_excludes"} selected={@params["player_deck_excludes"] || []} title="Exclude cards"/>
      <PlayableCardSelect id={"player_played_cards_includes"} format={@params["format"]} param={"player_played_cards_includes"} selected={@params["player_played_cards_includes"] || []} title="Played cards"/>
      <PlayableCardSelect id={"player_played_cards_excludes"} format={@params["format"]} param={"player_played_cards_excludes"} selected={@params["player_played_cards_excludes"] || []} title="Not Played cards"/>

      <div :if={@needs_class?}>
        Select a class before proceeding. I'd suggest selecting your other filters first.
      </div>
      <div :if={!@needs_class?}>
        <div :if={@card_popularity.loading}>
          Loading tournaments...
        </div>
        <div :if={@card_popularity.ok? && @archetypes.ok? && !@card_popularity.loading} class="table-scrolling-sticky-wrapper">
          <table class="table is-fullwidth is-striped tw-table">
            <thead>
              <th class="tw-bg-gray-700">Card</th>
              <th class="tw-bg-gray-700" :if={User.can_access?(@user, :archetyping)}>Archetype</th>
              <th class="tw-bg-gray-700" :on-click="change_sort" phx-value-sort_by={"total"}>
                {add_arrow("Times Played", "total", @params, true)}
              </th>
              <th class="tw-bg-gray-700 ":on-click="change_sort" phx-value-sort_by={archetype} :for={archetype <- @archetypes.result}>
                {add_arrow(archetype, to_string(archetype), @params)}
              </th>
            </thead>
            <tbody>
              <tr :for={{card, %{"total" => total} = popularity_map} <- sort_and_filter(@card_popularity.result, @min_played_count, @sort_by)} :if={{card_archetype} = {Backend.PlayedCardsArchetyper.archetype([card], @criteria["player_class"], @criteria["format"])}}>
                <td class="sticky-column">
                  <div class="decklist_card_container">
                    <DecklistCard :if={card = Backend.Hearthstone.get_card(card)} deck_class="NEUTRAL" card={card} decklist_options={Backend.UserManager.User.decklist_options(@user)}/>
                  </div>
                </td>
                <td :if={User.can_access?(@user, :archetyping)} class={if card_archetype |> to_string() |> String.starts_with?("Other "), do: "tw-text-red-500"}>{card_archetype}</td>
                <td>{total}</td>
                <td :for={archetype <- @archetypes.result} class={class(archetype, card_archetype)}>{Map.get(popularity_map, archetype, 0) |> Util.percent(total) |> Float.round(1)}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    """
  end

  defp class(archetype, card_archetype) do
    if to_string(archetype) == to_string(card_archetype) do
      "tw-font-bold tw-text-gray-500"
    end
  end

  def handle_params(params, _uri, socket) do
    default = %{
      "period" => PeriodDropdown.default(:public),
      "format" => 2,
      "rank" => "all"
    }

    criteria =
      Map.merge(default, params)
      |> Map.take([
        "period",
        "format",
        "rank",
        "player_class",
        "player_deck_includes",
        "player_deck_excludes",
        "player_played_cards_includes",
        "player_played_cards_excludes"
      ])

    min_played_count =
      Map.get(params, "min_played_count", @default_min_played_count) |> Util.to_int_or_orig()

    sort_by = Map.get(params, "sort_by", @default_sort_by)

    selected_params =
      default |> Map.merge(params) |> Map.merge(%{"min_played_count" => min_played_count})

    same_assigns = [
      criteria: criteria,
      params: params,
      sort_by: sort_by,
      min_played_count: min_played_count
    ]

    if Map.has_key?(criteria, "player_class") do
      {
        :noreply,
        socket
        |> assign(needs_class?: false)
        |> assign(same_assigns)
        |> update_context(selected_params)
        |> fetch_popularity(socket)
      }
    else
      {:noreply,
       socket
       |> assign(needs_class?: true)
       |> assign(same_assigns)
       |> update_context(selected_params)}
    end
  end

  # no need to fetch because the criteria hasn't changed
  defp fetch_popularity(%{assigns: %{criteria: new_criteria}} = new_socket, %{
         assigns: %{criteria: old_criteria}
       })
       when new_criteria == old_criteria do
    new_socket
  end

  defp fetch_popularity(socket, _old_socket) do
    criteria = socket.assigns.criteria

    socket
    |> assign_async([:card_popularity, :archetypes], fn ->
      fetch_card_popularity(criteria)
    end)
  end

  defp assign_can_access(%{assigns: %{user: user}} = socket) do
    can_access? = User.can_access?(user, :archetyping) or User.premium?(user)
    assign(socket, can_access?: can_access?)
  end

  defp update_context(socket, selected_params) do
    LivePatchDropdown.update_context(
      socket,
      __MODULE__,
      selected_params
    )
  end

  def fetch_card_popularity(criteria) do
    games = Hearthstone.DeckTracker.games_with_played_cards(criteria)
    {popularity, archetypes_popularity} = process_games(games)

    {:ok, %{card_popularity: popularity, archetypes: sorted_archetypes(archetypes_popularity)}}
  end

  def process_games(games) do
    Enum.reduce(games, {%{}, %{}}, fn
      %{player_deck: %{archetype: archetype}, played_cards: played_cards},
      {popularity, archetype_popularity} ->
        archetype = archetype |> to_string()

        pop =
          Enum.reduce(played_cards.player_cards, popularity, fn id, carry ->
            normalized_id = Hearthstone.DeckTracker.tally_card_id(id)

            carry
            |> update_in([Access.key(normalized_id, %{}), Access.key(archetype, 0)], &(&1 + 1))
            |> update_in([Access.key(normalized_id, %{}), Access.key("total", 0)], &(&1 + 1))
          end)

        arch_pop = update_in(archetype_popularity, [Access.key(archetype, 0)], &(&1 + 1))
        {pop, arch_pop}

      _, carry ->
        carry
    end)
  end

  defp sort_and_filter(card_played_popularity, min_played_count, sort_by) do
    sorter = sorter(sort_by)

    card_played_popularity
    |> Enum.filter(fn
      {_, %{"total" => total}} -> total >= min_played_count
      _ -> false
    end)
    |> Enum.sort_by(sorter, :desc)
  end

  defp sorter("total"), do: fn {_card, popularity} -> Map.get(popularity, "total", 0) end

  defp sorter(sort_by) do
    fn {_card, popularity} ->
      count = Map.get(popularity, sort_by, 0)
      total = Map.get(popularity, "total", 0)
      count / total
    end
  end

  defp sorted_archetypes(archetypes_map) do
    archetypes_map
    |> Enum.sort_by(fn {_arch, count} -> count end, :desc)
    |> Enum.map(fn {archetype, _count} -> archetype end)
  end

  def handle_event(
        "change_sort",
        sort,
        %{
          assigns: %{
            params: params
          }
        } = socket
      ) do
    new_params = Map.merge(params, sort)

    {:noreply,
     socket
     |> push_patch(
       to:
         LivePatchDropdown.link(
           BackendWeb.Endpoint,
           __MODULE__,
           nil,
           new_params
         )
     )}
  end
end
