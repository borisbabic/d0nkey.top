defmodule Components.CardsExplorer do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Backend.Hearthstone
  alias Components.Card
  alias Components.LivePatchDropdown
  alias Surface.Components.Form
  alias Surface.Components.Form.TextInput

  alias Components.Filter.{
    FormatDropdown,
    AttackDropdown,
    CardSetDropdown,
    HealthDropdown,
    ManaCostDropdown,
    MinionTypeDropdown,
    SpellSchoolDropdown,
    RarityDropdown,
    CardTypeDropdown,
    FactionDropdown,
    ClassDropdown
  }

  import Components.DecksExplorer, only: [parse_int: 2]

  data(streams, :list)
  slot(above_card, required: false)
  slot(below_card, required: false)
  data(end_of_stream?, :boolean, default: false)
  data(offset, :integer, default: 0)
  prop(scroll_size, :integer, default: 1)
  prop(format_filter, :boolean, default: true)
  prop(params, :map, required: true)
  prop(live_view, :module, required: true)
  prop(on_card_click, :event, default: nil)
  prop(default_order_by, :string, default: "latest")
  prop(default_limit, :string, default: 30)
  prop(additional_url_params, :map, default: %{})
  prop(card_disabled, :fun, default: &Util.always_nil/1)
  prop(card_pool, :any, default: true)
  prop(card_phx_hook, :string, default: nil)
  prop(class_options, :list, default: nil)

  ### how many times the limit do we keep in the viewport
  # @viewport_size_factor 7

  def update(assigns_old, socket) do
    %{
      default_order_by: default_order_by,
      default_limit: default_limit,
      additional_url_params: additional_url_params
    } = assigns_old

    assigns =
      Map.update!(assigns_old, :params, fn p ->
        add_default_params(p, default_order_by, default_limit)
      end)

    url_params = Map.merge(assigns_old.params, additional_url_params)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_stream_info(assigns)
      |> LivePatchDropdown.update_context(
        assigns.live_view,
        url_params,
        nil,
        assigns.params
      )
      |> init_stream()
    }
  end

  defp init_stream(socket) do
    %{offset: offset, scroll_size: scroll_size} = socket.assigns
    stream_cards(socket, offset, true, scroll_size)
    # case socket.assigns do
    # %{streams: %{cards: _}} -> socket
    # %{offset: offset} -> stream_cards(socket, offset, true)
    # end
  end

  defp assign_stream_info(socket, assigns) do
    case assigns do
      %{offset: offset} when is_integer(offset) ->
        socket

      _ ->
        assign(socket, offset: 0, end_of_stream?: false)
    end
  end

  defp add_default_params(old_params, default_order_by, default_limit) do
    {key, value} = Hearthstone.not_classic_card_criteria()

    old_params
    |> Map.put_new("order_by", default_order_by)
    |> Map.put_new("limit", default_limit)
    |> Map.put_new("collectible", "yes")
    |> Map.put_new(key, value)
  end

  defp stream_cards(socket, new_offset, reset \\ false, scroll_size \\ 1) when new_offset >= 0 do
    %{params: params, offset: curr_offset, card_pool: card_pool} = socket.assigns

    fetched_cards =
      params
      |> Map.update("limit", 30 * scroll_size, &(&1 * scroll_size))
      |> Map.put("offset", new_offset)
      |> Map.put(:card_pool, card_pool)
      |> Hearthstone.cards()

    handle_offset_stream_scroll(
      socket,
      :cards,
      fetched_cards,
      new_offset,
      curr_offset,
      nil,
      reset
    )
  end

  def render(assigns) do
    ~F"""
      <div>
        <FormatDropdown :if={@format_filter} id="cards_format_dropdown", options={[{"standard_2025", "2025 Standard"}, {2, "Standard"}, {1, "Wild"}]} />
        <CardSetDropdown id="card_set_dropdown" />
        <ManaCostDropdown id="cards_mana_cost_dropdown" />
        <AttackDropdown id="cards_attack_dropdown" />
        <HealthDropdown id="cards_attack_dropdown" />
        <ClassDropdown options={@class_options} id="class_dropdown" include_neutral={true}/>
        <CardTypeDropdown id="cards_card_type_dropdown" />
        <MinionTypeDropdown id="cards_minion_type_dropdown"/>
        <SpellSchoolDropdown id="cards_spell_school_dropdown" />
        <RarityDropdown id="cards_rarity_dropdown" />
        <FactionDropdown id="cards_faction_dropdown" />
        <!-- <LivePatchDropdown id="cards_collectible" param="collectible" title="Collectible" options={[{"no", "Uncollectible"}, {"yes", "Collectible"}]} /> -->
        <LivePatchDropdown id="order_by_dropdown" param="order_by" title="Sort" options={[{"latest", "Latest"}, {"mana", "Mana"}, {"mana_in_class", "Mana in Class"}]} />
        <Form for={%{}} as={:search} change="change" submit="change">
          <TextInput value={Map.get(@params, "search", "")} class="input has-text-black" opts={placeholder: "Search name/text"}/>
        </Form>
        <div
          id="cards_viewport"
          phx-update="stream"
          class="columns is-multiline is-mobile"
          phx-target={@myself}
          phx-viewport-bottom={!@end_of_stream? && "next-cards-page"}>
          <div card_id={c.id} id={id} :for={{id, c} <- @streams.cards} class={"column", "is-narrow", "is-clickable": !!@on_card_click, "not-in-list": @card_disabled.(c)} phx-value-card_id={c.id} :on-click={unless @card_disabled.(c), do: @on_card_click} phx-hook={@card_phx_hook}>
            <Card shrink_mobile={true} card={c} disable_link={!!@on_card_click}>
              <:above_image :let={card: card}>
                <#slot {@above_card, card: card} />
              </:above_image>
              <:below_image :let={card: card}>
                <#slot {@below_card, card: card} />
              </:below_image>
            </Card>
          </div>
        </div>
      </div>
    """
  end

  # def handle_event("previous-cards-page", %{"_overran" => true}, socket) do
  #   %{offset: offset, params: %{"limit" => limit}} = socket.assigns

  #   if offset <= (@viewport_size_factor - 1) * limit do
  #     {:noreply, socket}
  #   else
  #     {:noreply, stream_cards(socket, 0)}
  #   end
  # end

  # def handle_event("previous-cards-page", _, socket) do
  #   %{offset: offset, params: %{"limit" => limit}} = socket.assigns
  #   new_offset = Enum.max([offset - limit, 0])

  #   if new_offset == offset do
  #     {:noreply, socket}
  #   else
  #     {:noreply, stream_cards(socket, new_offset)}
  #   end
  # end

  def handle_event("next-cards-page", _middle, socket) do
    %{offset: offset, params: %{"limit" => limit}} = socket.assigns
    new_offset = offset + limit
    {:noreply, socket |> incr_scroll_size() |> stream_cards(new_offset)}
  end

  def handle_event("change", %{"search" => [search_input]}, socket) do
    %{params: params} = socket.assigns
    long_enough = String.length(search_input) >= 3

    new_params =
      case {Map.get(params, "search"), long_enough} do
        {nil, false} -> params
        {nil, true} -> Map.put(params, "search", search_input)
        {_, false} -> Map.drop(params, ["search"])
        {_, true} -> Map.put(params, "search", search_input)
      end

    send(self(), {:update_filters, new_params})
    {:noreply, socket}
  end

  defp incr_scroll_size(%{assigns: %{scroll_size: scroll_size}} = socket) do
    push_patch(socket,
      to: LivePatchDropdown.link_with_new_url_param(socket, "scroll_size", scroll_size + 1)
    )
  end

  def filter_relevant(params) do
    Map.take(params, [
      "limit",
      "class",
      "attack",
      "card_type",
      "health",
      "mana_cost",
      "collectible",
      "minion_type",
      "rarity",
      "faction",
      "spell_school",
      "card_set_id",
      "card_set_group_slug",
      "order_by",
      "search",
      "format",
      "rarity"
    ])
    |> parse_int(["limit"])
  end

  # defp use_fake_limit(old_params) do
  #   {limit, temp_params} = Map.pop(old_params, "limit")
  #   fake_limit = Util.to_int_or_orig(limit) * @fake_limit_factor
  #   new_params = Map.put_new(temp_params, "fake_limit", fake_limit)
  #   {limit, new_params}
  # end
end
