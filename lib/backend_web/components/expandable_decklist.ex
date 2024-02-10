defmodule Components.ExpandableDecklist do
  @moduledoc false
  alias Components.Decklist
  use Surface.LiveComponent

  prop(deck, :map, required: true)
  prop(name, :string, default: nil)
  prop(show_cards, :boolean, default: false)
  prop(guess_archetype, :boolean, default: false)

  defmacro __using__(_opts_) do
    quote do
      alias Components.ExpandableDecklist

      def handle_event("toggle_cards", params, socket) do
        ExpandableDecklist.toggle_cards(params)

        {
          :noreply,
          socket
        }
      end
    end
  end

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
          <span phx-click="toggle_cards" phx-value-id={@id} phx-value-show_cards={!@show_cards} class="is-clickable" >
            <HeroIcons.eye size="small" :if={!@show_cards}/>
            <HeroIcons.eye_slash size="small" :if={@show_cards}/>
          </span>
        </:right_button>
      </Decklist>
    """
  end

  def toggle_cards(%{"id" => id, "show_cards" => show_cards}) do
    send_update(__MODULE__, id: id, show_cards: show_cards)
  end

  def toggle_cards(%{"id" => id}), do: toggle_cards(%{"id" => id, "show_cards" => false})
end
