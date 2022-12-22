defmodule Components.Decklist do
  @moduledoc false
  use Surface.Component
  alias Components.CardsList
  alias Backend.Hearthstone.Deck
  alias Backend.HearthstoneJson.Card
  use BackendWeb.ViewHelpers

  prop(deck, :map, required: true)
  prop(name, :string, required: false)
  prop(archetype_as_name, :boolean, default: true)
  prop(show_cards, :boolean, default: true)
  prop(comparison, :any, required: false)
  prop(highlight_rotation, :boolean, default: false)
  prop(show_hero, :any, default: true)
  slot(right_button)

  @spec deck_name(Map.t() | nil, Deck.t(), Card.t()) :: String.t()
  def deck_name(%{name: name}, _, _) when is_binary(name) and bit_size(name) > 0, do: name

  def deck_name(assigns = %{archetype_as_name: true}, deck, hero) do
    with nil <- deck.archetype,
         nil <- Backend.Hearthstone.DeckArchetyper.archetype(deck) do
      Map.put(assigns, :archetype_as_name, false) |> deck_name(deck, hero)
    end
  end

  def deck_name(_, %{class: c}, _) when is_binary(c), do: c |> Deck.class_name()
  def deck_name(_, _, %{card_class: c}) when is_binary(c), do: c |> Deck.class_name()
  def deck_name(_, _, _), do: ""

  @spec deck_class(Deck.t(), Card.t()) :: String.t()
  defp deck_class(%{class: c}, _) when is_binary(c), do: c
  defp deck_class(_, %{card_class: c}) when is_binary(c), do: c
  defp deck_class(_, _), do: "NEUTRAL"

  defp link_part(%{id: id}) when not is_nil(id), do: id
  defp link_part(%{deckcode: deckcode}), do: deckcode

  def render(assigns) do
    deck = assigns[:deck]

    hero = Backend.HearthstoneJson.get_hero(deck)

    deck_class = deck_class(deck, hero)
    class_class = deck_class |> String.downcase()

    name = deck_name(assigns, deck, hero) |> add_runes(deck) |> add_xl(deck)

    ~F"""
      <div>

          <div :if={@show_hero} class={"decklist-hero",  class_class} style="margin-bottom: 0px;">
              <div class="level is-mobile">
                  <div :if={deckcode = Deck.deckcode(@deck)} phx-click="deck_copied" phx-value-deckcode={deckcode} class="level-left">
                      {render_deckcode(deckcode, false)}
                  </div>
                  <div class="level-left deck-text">
                    <div class="deck-title">
                      <span><span style="font-size:0;">### </span> <a class={"basic-black-text"} href={"/deck/#{link_part(@deck)}"}>{name}</a>
                      <span style="font-size: 0; line-size:0; display:block">
                      {Deck.deckcode(@deck)}</span></span>
                    </div>
                  </div>
                  <div class="level-right">
                      <#slot name="right_button"/>
                  </div>
              </div>
          </div>
          <div :if={@show_cards}>
            <CardsList comparison={@comparison} cards={deck.cards} deck_class={deck_class} highlight_rotation={@highlight_rotation}/>
          </div>
          <span style="font-size: 0; line-size:0; display:block">
            # You really like to select a lot of stuff, don't ya you beautiful being! 🤎 D0nkey
          </span>
      </div>
    """
  end

  defp add_xl(name, %{cards: cards}) when is_list(cards) do
    if Enum.count(cards) == 40 do
      "XL #{name}"
    else
      name
    end
  end

  defp add_xl(name, _), do: name

  defp add_runes(name, %{cards: cards} = deck) when is_list(cards) do
    deck
    |> Deck.rune_cost()
    |> Hearthstone.Card.RuneCost.shorthand()
    # next two lines append " " if it's not empty
    |> Kernel.<>(" ")
    |> String.trim_leading()
    |> Kernel.<>(to_string(name))
  end

  defp add_runes(name, _), do: name
end
