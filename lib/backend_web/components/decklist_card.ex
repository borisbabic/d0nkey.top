defmodule Components.DecklistCard do
  use Surface.Component
  alias Backend.HearthstoneJson
  prop(count, :integer, required: true)
  prop(card, :map, required: true)
  defp classes("FREE"), do: classes("COMMON")

  defp classes(rarity) do
    lower = rarity |> String.downcase()
    {"background-dark-#{lower}", "gradient-dark-#{lower}"}
  end

  def render(assigns) do
    card = assigns[:card]
    html_id = "card-#{card.id}"
    tile_url = card.id |> HearthstoneJson.tile_url()
    card_url = card.id |> HearthstoneJson.tile_url()
    {background_class, gradient_class} = classes(card.rarity)

    ~H"""
    <div style="background-image: url('{{ tile_url }}');" class="decklist-card {{ html_id }}">
      <span class="card-number {{ background_class }} is-unselectable">{{ card.cost }}</span>
      <span class="card-name {{ gradient_class }}"><span style="font-size: 0;"># {{ @count }}x ({{ @card.cost }}) </span>{{ card.name }}</span>
      <span class="card-number {{ background_class }} is-unselectable"> {{ @count }}</span>
    </div>
    <div></div>
    """
  end
end
