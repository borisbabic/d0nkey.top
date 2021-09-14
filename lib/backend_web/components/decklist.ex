defmodule Components.Decklist do
  @moduledoc false
  use Surface.Component
  alias Components.CardsList
  alias Backend.Hearthstone.Deck
  alias Backend.HearthstoneJson.Card
  use BackendWeb.ViewHelpers
  prop(deck, :map, required: true)
  prop(name, :string, required: false)
  prop(show_cards, :boolean, default: true)
  prop(comparison, :any, required: false)
  prop(highlight_rotation, :boolean, default: false)
  prop(show_hero, :any, default: true)
  slot(right_button)

  @spec deck_name(String.t() | nil, Deck.t(), Card.t()) :: String.t()
  def deck_name(name, _, _) when is_binary(name) and bit_size(name) > 0, do: name
  def deck_name(_, %{class: c}, _) when is_binary(c), do: c |> Deck.class_name()
  def deck_name(_, _, %{card_class: c}) when is_binary(c), do: c |> Deck.class_name()
  def deck_name(_, _, _), do: ""

  @spec deck_class(Deck.t(), Card.t()) :: String.t()
  defp deck_class(%{class: c}, _) when is_binary(c), do: c
  defp deck_class(_, %{card_class: c}) when is_binary(c), do: c
  defp deck_class(_, _), do: "NEUTRAL"

  def render(assigns) do
    deck = assigns[:deck]

    hero = Backend.HearthstoneJson.get_hero(deck)
    deckcode = render_deckcode(deck.deckcode, false)

    deck_class = deck_class(deck, hero)
    class_class = deck_class |> String.downcase()

    name = deck_name(assigns[:name], deck, hero)

    ~H"""
      <div>

          <div :if={{ @show_hero }} class=" decklist-hero {{ class_class }}" style="margin-bottom: 0px;"> 
              <div class="level is-mobile">
                  <div phx-click="deck_copied" phx-value-deckcode="{{ deck.deckcode }}" class="level-left"> 
                      {{ deckcode }}
                  </div>
                  <div class="level-left deck-text deck-title"> 
                    <span><span style="font-size:0;">### </span> <span>{{ name }}</span>
    <span style="font-size: 0; line-size:0; display:block">
    {{ @deck |> Deck.deckcode() }}</span></span>
                  </div> 
                  <div class="level-right"> 
                      <slot name="right_button"/>
                  </div>
              </div>
          </div>
          <div :if={{ @show_cards }}>
            <CardsList comparison={{ @comparison }} cards={{ deck.cards }} deck_class={{ deck_class }} highlight_rotation={{ @highlight_rotation }}/>
          </div>
          <span style="font-size: 0; line-size:0; display:block">
            # You really like to select a lot of stuff, don't ya you beautiful being! 🤎 D0nkey
          </span>
      </div>
    """
  end
end
