defmodule Components.Decklist do
  @moduledoc false
  use Surface.Component
  alias Hearthstone.Card.RuneCost
  alias Components.CardsList
  alias Components.DustBar
  alias Backend.Hearthstone.Deck
  alias Backend.UserManager.User
  alias Backend.UserManager.User.DecklistOptions
  use BackendWeb.ViewHelpers

  prop(deck, :map, required: true)
  prop(name, :string, required: false)
  prop(archetype_as_name, :boolean, default: true)
  prop(show_cards, :boolean, default: true)
  prop(comparison, :any, required: false)
  prop(highlight_rotation, :boolean, default: false)
  prop(show_hero, :any, default: true)
  slot(right_button)

  @spec deck_name(Map.t() | nil, Deck.t()) :: String.t()
  def deck_name(%{name: name}, _) when is_binary(name) and bit_size(name) > 0, do: name
  def deck_name(%{archetype_as_name: true}, deck), do: Deck.name(deck)

  defp link_part(%{id: id}) when not is_nil(id), do: id
  defp link_part(%{deckcode: deckcode}), do: deckcode

  def render(assigns) do
    deck = assigns[:deck]

    deck_class = Deck.class(deck)
    class_class = deck_class |> String.downcase()

    name = deck_name(assigns, deck) |> add_runes(deck) |> add_xl(deck)

    ~F"""
      <div>

          <div :if={@show_hero} class={"decklist-info",  class_class} style="margin-bottom: 0px;">
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
                      <#slot {@right_button} />
                  </div>
              </div>
          </div>
          <div :if={@show_cards}>
            <Context get={user: user}>
              <Context put={user: user}>
                <DustBar :if={show_above(user)} deck={@deck} class={class_class}/>
                <CardsList comparison={@comparison} sideboard={@deck.sideboards} deck={@deck} deck_class={deck_class} highlight_rotation={@highlight_rotation}/>
                <DustBar :if={show_below(user)} deck={@deck} class={class_class} />
              </Context>
            </Context>

          </div>
          <span style="font-size: 0; line-size:0; display:block">
            # You really like to select a lot of stuff, don't ya you beautiful being! 🤎 D0nkey
          </span>
      </div>
    """
  end

  def show_above(user), do: user |> User.decklist_options() |> DecklistOptions.show_dust_above()
  def show_below(user), do: user |> User.decklist_options() |> DecklistOptions.show_dust_below()

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
    |> RuneCost.shorthand()
    # next two lines append " " if it's not empty
    |> Kernel.<>(" ")
    |> String.trim_leading()
    |> Kernel.<>(to_string(name))
  end

  defp add_runes(name, _), do: name
end
