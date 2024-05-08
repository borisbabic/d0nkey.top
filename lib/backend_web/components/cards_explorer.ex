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
  prop(params, :map, required: true)
  prop(live_view, :module, required: true)

  @default_limit 30
  @fake_limit_factor 4

  def update(assigns_old, socket) do
    assigns = Map.update!(assigns_old, :params, &add_default_params/1)

    {
      :ok,
      socket
      |> assign(assigns)
      |> LivePatchDropdown.update_context(
        assigns.live_view,
        assigns_old.params,
        nil,
        assigns.params
      )
      |> stream_cards()
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

  defp stream_cards(socket) do
    cards = cards(socket)
    stream(socket, :cards, cards)
  end

  def render(assigns) do
    ~F"""
      <div>
        <FormatDropdown id="cards_format_dropdown", options={[{2, "Standard"}, {1, "Wild"}]} />
        <ClassDropdown id="class_dropdown"/>
        <CardTypeDropdown id="cards_card_type_dropdown" param="card_type" title="Card Type" />
        <ManaCostDropdown id="cards_mana_cost_dropdown" />
        <AttackDropdown id="cards_attack_dropdown" />
        <HealthDropdown id="cards_attack_dropdown" />
        <!-- <LivePatchDropdown id="cards_collectible" param="collectible" title="Collectible" options={[{"no", "Uncollectible"}, {"yes", "Collectible"}]} /> -->
        <LivePatchDropdown id="order_by_dropdown" param="order_by" title="Sort" options={[{"latest", "Latest"}, {"mana", "Mana"}, {"mana_in_class", "Mana in Class"}]} />
        <div class="columns is-multiline is-mobile">
          <div :for={{id, c} <- @streams.cards} class="column is-narrow">
            <Card id={id} card={c} />
          </div>
        </div>
      </div>
    """
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

  defp cards(%{assigns: %{params: params}}), do: cards(params)

  defp cards(raw_params) do
    {limit, new_params} = use_fake_limit(raw_params)

    new_params
    |> Hearthstone.cards()
    |> Enum.take(limit)
  end

  defp use_fake_limit(old_params) do
    {limit, temp_params} = Map.pop(old_params, "limit")
    fake_limit = Util.to_int_or_orig(limit) * @fake_limit_factor
    new_params = Map.put_new(temp_params, "fake_limit", fake_limit)
    {limit, new_params}
  end
end
