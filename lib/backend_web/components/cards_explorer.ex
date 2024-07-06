defmodule Components.CardsExplorer do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Backend.Hearthstone
  alias Components.Card
  alias Components.LivePatchDropdown

  alias Components.Filter.{
    FormatDropdown,
    AttackDropdown,
    HealthDropdown,
    ManaCostDropdown,
    CardTypeDropdown,
    ClassDropdown
  }

  import Components.DecksExplorer, only: [parse_int: 2]

  data(streams, :list)
  data(end_of_timeline?, :boolean, default: false)
  data(offset, :integer, default: 0)
  prop(params, :map, required: true)
  prop(live_view, :module, required: true)

  @default_limit 30
  ### how many times the limit do we keep in the viewport
  @viewport_size_factor 7

  def update(assigns_old, socket) do
    assigns = Map.update!(assigns_old, :params, &add_default_params/1)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(offset: 0, end_of_timeline?: false)
      |> LivePatchDropdown.update_context(
        assigns.live_view,
        assigns_old.params,
        nil,
        assigns.params
      )
      |> stream_cards(0, true)
    }
  end

  defp add_default_params(old_params) do
    {key, value} = Hearthstone.not_classic_card_criteria()

    old_params
    |> Map.put_new("order_by", "latest")
    |> Map.put_new("limit", @default_limit)
    |> Map.put_new("collectible", "yes")
    |> Map.put_new(key, value)
  end

  defp stream_cards(socket, new_offset, reset \\ false) when new_offset >= 0 do
    %{params: params, offset: curr_offset} = socket.assigns
    %{"limit" => limit} = params
    fetched_cards = params |> Map.put("offset", new_offset) |> Hearthstone.cards()

    {cards, at, stream_limit} =
      if new_offset >= curr_offset do
        {fetched_cards, -1, limit * @viewport_size_factor * -1}
      else
        {Enum.reverse(fetched_cards), 0, limit * @viewport_size_factor}
      end

    case cards do
      [] ->
        assign(socket, end_of_timeline?: true)

      [_ | _] = cards ->
        socket
        |> assign(end_of_timeline?: false)
        |> assign(:offset, new_offset)
        |> stream(:cards, cards, at: at, limit: stream_limit, reset: reset)
    end
  end

  def render(assigns) do
    ~F"""
      <div>
        <FormatDropdown id="cards_format_dropdown", options={[{2, "Standard"}, {1, "Wild"}]} />
        <ClassDropdown id="class_dropdown" include_neutral={true}/>
        <CardTypeDropdown id="cards_card_type_dropdown" param="card_type" title="Card Type" />
        <ManaCostDropdown id="cards_mana_cost_dropdown" />
        <AttackDropdown id="cards_attack_dropdown" />
        <HealthDropdown id="cards_attack_dropdown" />
        <!-- <LivePatchDropdown id="cards_collectible" param="collectible" title="Collectible" options={[{"no", "Uncollectible"}, {"yes", "Collectible"}]} /> -->
        <LivePatchDropdown id="order_by_dropdown" param="order_by" title="Sort" options={[{"latest", "Latest"}, {"mana", "Mana"}, {"mana_in_class", "Mana in Class"}]} />
        <div
          id="cards_viewport"
          phx-update="stream"
          class="columns is-multiline is-mobile"
          phx-target={@myself}
          phx-viewport-bottom={!@end_of_timeline? && "next-cards-page"}
          phx-viewport-top={"previous-cards-page"}>
          <div id={id} :for={{id, c} <- @streams.cards} class="column is-narrow">
            <Card card={c} />
          </div>
        </div>
      </div>
    """
  end

  def handle_event("previous-cards-page", %{"_overran" => true}, socket) do
    {:noreply, stream_cards(socket, 0)}
  end

  def handle_event("previous-cards-page", _, socket) do
    %{offset: offset, params: %{"limit" => limit}} = socket.assigns
    new_offset = Enum.max([offset - limit, 0])
    {:noreply, stream_cards(socket, new_offset)}
  end

  def handle_event("next-cards-page", _middle, socket) do
    %{offset: offset, params: %{"limit" => limit}} = socket.assigns
    new_offset = offset + limit
    {:noreply, stream_cards(socket, new_offset)}
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
      "order_by",
      "format",
      "rarity"
    ])
    |> parse_int(["limit", "format"])
  end

  # defp use_fake_limit(old_params) do
  #   {limit, temp_params} = Map.pop(old_params, "limit")
  #   fake_limit = Util.to_int_or_orig(limit) * @fake_limit_factor
  #   new_params = Map.put_new(temp_params, "fake_limit", fake_limit)
  #   {limit, new_params}
  # end
end
