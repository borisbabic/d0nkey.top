defmodule BackendWeb.ArchetypeMappingTable do
  @moduledoc "Internal helper for archetyping based on played cards"
  use BackendWeb, :surface_live_view
  import Components.CardStatsTable, only: [add_arrow: 3]
  alias Backend.UserManager.User
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.FormatDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.ClassDropdown
  alias Components.Filter.PlayableCardSelect
  alias Components.LivePatchDropdown
  alias Components.WinrateTag

  @default_min_played_count 100
  @default_sort_by "total"
  @default_x_axis "player_deck_archetype"
  data(user, :any)
  data(needs_class?, :boolean, default: false)
  data(can_access?, :boolean, default: false)
  data(archetype_mapping, :any)
  data(params, :map, default: %{})
  data(criteria, :map, default: %{})
  data(sort_by, :string, default: @default_sort_by)
  data(min_played_count, :integer, default: @default_min_played_count)
  data(x_axis, :string, default: @default_x_axis)
  data(sorted_x_axis, :any)

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
      <div class="title is-2">Archetype Mappings</div>
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
      <LivePatchDropdown
        id="x_axis"
        options={["player_archetype", "player_deck_archetype"]}
        title={"X Axis"}
        param={"x_axis"}
        normalizer={&to_string/1} />
      <PlayableCardSelect id={"player_deck_includes"} format={@params["format"]} param={"player_deck_includes"} selected={@params["player_deck_includes"] || []} title="Include cards"/>
      <PlayableCardSelect id={"player_deck_excludes"} format={@params["format"]} param={"player_deck_excludes"} selected={@params["player_deck_excludes"] || []} title="Exclude cards"/>
      <PlayableCardSelect id={"player_played_cards_includes"} format={@params["format"]} param={"player_played_cards_includes"} selected={@params["player_played_cards_includes"] || []} title="Played cards"/>
      <PlayableCardSelect id={"player_played_cards_excludes"} format={@params["format"]} param={"player_played_cards_excludes"} selected={@params["player_played_cards_excludes"] || []} title="Not Played cards"/>

      <div :if={@needs_class?}>
        Select a class before proceeding. I'd suggest selecting your other filters first.
      </div>
      <div :if={!@needs_class?}>
        <div :if={@archetype_mapping.loading}>
          Loading tournaments...
        </div>
        <div :if={@archetype_mapping.ok? && !@archetype_mapping.loading} class="table-scrolling-sticky-wrapper">
          <table class="table is-fullwidth is-striped tw-table">
            <thead>
              <th class="tw-bg-gray-700" >Archetype</th>
              <th class="tw-bg-gray-700" :on-click="change_sort" phx-value-sort_by="total">Total</th>
              <th class="tw-bg-gray-700" :on-click="change_sort" phx-value-sort_by={archetype} :for={archetype <- @sorted_x_axis.result}>
                {add_arrow(archetype, to_string(archetype), @params)}
              </th>
            </thead>
            <tbody>
              <tr :for={{y_axis, popularity_map} <- sort_and_filter(@archetype_mapping.result, @min_played_count, @sort_by)}>
                <td class="sticky-column">
                  {y_axis}
                </td>
                <td>
                  {Map.get(popularity_map, "total", 0)}
                </td>
                <td :for={archetype <- @sorted_x_axis.result}><WinrateTag offset={-0.3} min_for_color={0.4} winrate={Map.get(popularity_map, archetype, 0) |> Util.percent(Map.get(popularity_map, "total", 0)) |> Kernel./(100)} /></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    """
  end

  def handle_params(params, _uri, socket) do
    default = %{
      "period" => PeriodDropdown.default(:public),
      "format" => "2",
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

    x_axis = Map.get(params, "x_axis", @default_x_axis)

    same_assigns = [
      criteria: criteria,
      params: params,
      sort_by: sort_by,
      min_played_count: min_played_count,
      x_axis: x_axis
    ]

    selected_params =
      default
      |> Map.merge(params)
      |> Map.merge(%{"min_played_count" => min_played_count, "x_axis" => x_axis})

    if Map.has_key?(criteria, "player_class") do
      {
        :noreply,
        socket
        |> assign(needs_class?: false)
        |> assign(same_assigns)
        |> update_context(selected_params)
        |> fetch_mapping(socket)
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
  defp fetch_mapping(%{assigns: %{criteria: new_criteria, x_axis: new_x_axis}} = new_socket, %{
         assigns: %{criteria: old_criteria, x_axis: old_x_axis}
       })
       when new_criteria == old_criteria and new_x_axis == old_x_axis do
    new_socket
  end

  defp fetch_mapping(socket, _old_socket) do
    criteria = socket.assigns.criteria
    x_axis = Map.get(socket.assigns, :x_axis, @default_x_axis)

    socket
    |> assign_async([:archetype_mapping, :sorted_x_axis], fn ->
      fetch_archetype_mapping(criteria, x_axis)
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

  def fetch_archetype_mapping(criteria, x_axis) do
    {raw_mapping, x_axis_popularity} =
      Hearthstone.DeckTracker.archetype_mapping(criteria) |> process_mapping(x_axis)

    sorted_x_axis = Enum.sort_by(x_axis_popularity, &elem(&1, 1), :desc) |> Enum.map(&elem(&1, 0))
    mappings = Map.values(raw_mapping) |> Enum.reduce(%{}, &Map.merge/2)

    {:ok, %{archetype_mapping: mappings, sorted_x_axis: sorted_x_axis}}
  end

  def process_mapping(mappings, x_axis_field) do
    {x_axis, y_axis} =
      if x_axis_field == "player_archetype" do
        {:player_archetype, :player_deck_archetype}
      else
        {:player_deck_archetype, :player_archetype}
      end

    mappings
    |> Enum.group_by(&Map.get(&1, y_axis))
    |> Enum.reduce({%{}, %{}}, fn {player_archetype, db_mappings},
                                  {carry_mappings, x_axis_popularity} ->
      {map, x_axis_popularity} =
        Enum.reduce(db_mappings, {%{}, x_axis_popularity}, fn mapping,
                                                              {carry, x_axis_popularity} ->
          archetype = Map.get(mapping, x_axis) |> to_string()
          count = Map.get(mapping, :count, 0)

          new_carry =
            carry
            |> update_in(
              [Access.key(player_archetype, %{}), Access.key(archetype, 0)],
              &(&1 + count)
            )
            |> update_in(
              [Access.key(player_archetype, %{}), Access.key("total", 0)],
              &(&1 + count)
            )

          new_x_axis_popularity =
            update_in(x_axis_popularity, [Access.key(archetype, 0)], &(&1 + count))

          {new_carry, new_x_axis_popularity}
        end)

      {Map.put(carry_mappings, player_archetype, map), x_axis_popularity}
    end)
  end

  defp sort_and_filter(archetype_mapping_popularity, min_played_count, sort_by) do
    sorter = sorter(sort_by)

    archetype_mapping_popularity
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
