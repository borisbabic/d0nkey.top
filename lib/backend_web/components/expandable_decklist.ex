defmodule Components.ExpandableDecklist do
  @moduledoc false
  alias Components.Decklist
  use Surface.LiveComponent

  prop(deck, :map, required: true)
  prop(name, :string, default: nil)
  prop(show_cards, :boolean, default: false)
  prop(guess_archetype, :boolean, default: false)

  def render(assigns = %{name: n, guess_archetype: ga, deck: d}) do
    name =
      with nil <- n,
           true <- ga,
           %{name: name} <- Backend.HSReplay.guess_archetype(d) do
        name
      else
        _ -> n
      end

    ~F"""
      <Decklist deck={@deck} show_cards={@show_cards} name={name}>
        <:right_button>
          <span :on-click="toggle_cards" class="is-clickable" >
            <HeroIcons.eye size="small" :if={!@show_cards}/>
            <HeroIcons.eye_slash size="small" :if={@show_cards}/>
          </span>
        </:right_button>
      </Decklist>
    """
  end

  def handle_event("toggle_cards", _, socket) do
    {:noreply, socket |> assign(show_cards: !socket.assigns.show_cards)}
  end
end
