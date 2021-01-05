defmodule Components.DecklistCard do
  @moduledoc false
  use Surface.Component
  alias Backend.HearthstoneJson
  prop(count, :integer, required: true)
  prop(card, :map, required: true)
  prop(deck_class, :string, default: "NEUTRAL")
  prop(show_mana_cost, :boolean, default: true)
  defp rarity("FREE"), do: rarity("COMMON")
  defp rarity(rarity), do: rarity |> String.downcase()
  defp class(class), do: class |> String.downcase()

  defp color_option(:rarity, %{rarity: rarity}), do: "var(--color-dark-#{rarity})"
  defp color_option(:card_class, %{card_class: card_class}), do: "var(--color-#{card_class})"
  defp color_option(:deck_class, %{deck_class: deck_class}), do: "var(--color-#{deck_class})"
  defp color_option(_, _), do: "var(--color-darker-grey)"

  defp colors(%{rarity: rarity, card_class: card_class}, deck_class, opts \\ %{}) do
    %{border: border, gradient: gradient} =
      %{
        border: :dark_grey,
        gradient: :rarity
      }
      |> Map.merge(opts)

    color_opts = %{
      rarity: rarity(rarity),
      card_class: class(card_class),
      deck_class: class(deck_class)
    }

    %{
      border: color_option(border, color_opts),
      gradient: color_option(gradient, color_opts)
    }
  end

  def render(assigns) do
    card = assigns[:card]
    html_id = "card-#{card.id}"
    tile_url = card.id |> HearthstoneJson.tile_url()
    # card_url = card.id |> HearthstoneJson.tile_url()
    %{border: border, gradient: gradient} = colors(card, assigns[:deck_class])
    # rarity_color = "--color-dark-#{rarity(card.rarity)}"
    # deck_class_color = "--color-#{class(card.card_class)}"

    ~H"""
    <div style="background-image: url('{{ tile_url }}'); --color-border: {{ border }} ; --color-gradient: {{ gradient }};" class="decklist-card {{ html_id }} is-flex is-align-items-center">
      <span class="deck-text decklist-card-background" style=" padding-left: 0.5ch;"></span>
      <span :if={{ @show_mana_cost }}class="card-number deck-text decklist-card-background is-unselectable has-text-left" style="width: 3ch;">{{ card.cost }}</span>
      <span class="card-name deck-text decklist-card-gradient has-text-left is-clipped"><span style="font-size: 0;"># {{ @count }}x ({{ @card.cost }}) </span>{{ card.name }}</span>
      <span style="padding-left:0.5ch; padding-right: 0.5ch; width: 1ch;" class="has-text-right card-number deck-text decklist-card-background is-unselectable"> {{ @count }}</span>
    </div>
    <div></div>
    """
  end
end
