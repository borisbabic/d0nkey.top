defmodule Components.Decklist do
  @moduledoc false
  use BackendWeb, :surface_component
  alias Components.CardsList
  alias Components.DustBar
  alias Backend.Hearthstone.Deck
  alias Backend.UserManager.User
  alias Backend.UserManager.User.DecklistOptions

  prop(deck, :map, required: true)
  prop(name, :string, required: false)
  prop(archetype_as_name, :boolean, default: true)
  prop(show_cards, :boolean, default: true)
  prop(comparison, :any, required: false)
  prop(highlight_rotation, :boolean, default: false)
  prop(show_hero, :any, default: true)
  prop(user, :map, from_context: :user)
  prop(link_to_archetype, :boolean, default: false)
  prop(on_card_click, :event, default: nil)
  slot(right_button)

  @spec deck_name(Deck.t(), String.t() | nil, boolean) :: String.t()
  def deck_name(_deck, name, _archetype_as_name) when is_binary(name) and bit_size(name) > 0,
    do: name

  def deck_name(deck, _name, true), do: Deck.name(deck)
  def deck_name(deck, _name, _archetype_as_name), do: Deck.class_name(deck)

  def deck_link(deck, false), do: ~p"/deck/#{link_part(deck)}"

  def deck_link(deck, true) do
    case Deck.archetype(deck) do
      nil -> deck_link(deck, false)
      archetype -> ~p"/archetype/#{archetype}?#{add_games_filters(deck)}"
    end
  end

  defp link_part(%{id: id}) when not is_nil(id), do: id
  defp link_part(%{deckcode: deckcode}), do: deckcode

  def render(assigns) do
    deck = assigns[:deck]

    deck_class = Deck.class(deck)
    class_class = deck_class |> String.downcase()

    ~F"""
      <div>

          <div :if={@show_hero} class={"decklist-info",  class_class} style="margin-bottom: 0px;">
              <div class="level is-mobile">
                  <div :if={deckcode = Deck.deckcode(@deck)} phx-click="deck_copied" phx-value-deckcode={deckcode} class="level-left">
                      {render_deckcode(deckcode, false)}
                  </div>
                  <div class="level-left deck-text">
                    <h2 class="deck-title">
                      <span><span style="font-size:0;">### </span> <a class={"basic-black-text"} href={deck_link(@deck, @link_to_archetype)}>{deck_name(@deck, @name, @archetype_as_name)}</a>
                      <span style="font-size: 0; line-size:0; display:block">
                      {Deck.deckcode(@deck)}</span></span>
                    </h2>
                  </div>
                  <div class="level-right">
                      <#slot {@right_button} />
                  </div>
              </div>
          </div>
          <div :if={@show_cards}>
            <DustBar :if={show_above(@user)} deck={@deck} class={class_class}/>
            <CardsList on_card_click={@on_card_click} comparison={@comparison} deck={@deck} deck_class={deck_class} highlight_rotation={@highlight_rotation}/>
            <DustBar :if={show_below(@user)} deck={@deck} class={class_class} />

          </div>
          <span style="font-size: 0; line-size:0; display:block">
            # You really like to select a lot of stuff, don't ya you beautiful being! 🤎 D0nkey
          </span>
      </div>
    """
  end

  def show_above(user), do: user |> User.decklist_options() |> DecklistOptions.show_dust_above()
  def show_below(user), do: user |> User.decklist_options() |> DecklistOptions.show_dust_below()
end
