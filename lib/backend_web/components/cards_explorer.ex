defmodule Components.CardsExplorer do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Backend.Hearthstone
  alias Components.Card

  prop(filters, :map, required: true)
  data(streams, :list)
  @default_limit 30
  @fake_limit_factor 4

  def update(assigns_old, socket) do
    assigns_new = Map.update!(assigns_old, :filters, &add_default_filters/1)

    {
      :ok,
      socket
      |> assign(assigns_new)
      |> stream_cards()
    }
  end

  defp add_default_filters(old_filters) do
    old_filters
    |> Map.put_new("order_by", "latest")
    |> Map.put_new("limit", @default_limit)
    |> Map.put_new("collectible", "yes")
  end

  defp stream_cards(socket) do
    cards = cards(socket)
    stream(socket, :cards, cards)
  end

  def render(assigns) do
    ~F"""
      <div class="columns is-multiline is-mobile">
        <div :for={{id, c} <- @streams.cards} class="column is-narrow">
          <Card id={id} card={c} />
        </div>

      </div>
    """
  end

  def filter_relevant(params) do
    Map.take(params, [
      "limit",
      "class",
      "attack",
      "health",
      "mana_cost",
      "collectible",
      "order_by",
      "format",
      "rarity"
    ])
  end

  defp cards(%{assigns: %{filters: filters}}), do: cards(filters)

  defp cards(raw_filters) do
    {limit, new_filters} = use_fake_limit(raw_filters)

    new_filters
    |> Hearthstone.cards()
    |> Enum.take(limit)
  end

  defp use_fake_limit(old_filters) do
    {limit, temp_filters} = Map.pop(old_filters, "limit")
    fake_limit = Util.to_int_or_orig(limit) * @fake_limit_factor
    new_filters = Map.put_new(temp_filters, "fake_limit", fake_limit)
    {limit, new_filters}
  end
end
