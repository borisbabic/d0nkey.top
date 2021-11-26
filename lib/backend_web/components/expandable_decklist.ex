defmodule Components.ExpandableDecklist do
  @moduledoc false
  alias Components.Decklist
  use Surface.LiveComponent

  prop(deck, :map, required: true)
  prop(name, :string, default: nil)
  prop(show_cards, :boolean, default: false)
  prop(guess_archetype, :boolean, default: false)

  def render(assigns = %{name: n, guess_archetype: ga, deck: d}) do
    name = with nil <- n,
        true <- ga,
        %{name: name} <- Backend.HSReplay.guess_archetype(d) do
      name
    else
      _ -> n
    end

    ~H"""
      <Decklist deck={{ @deck }} show_cards={{ @show_cards }} name={{ name }}>
        <template slot="right_button">
          <span phx-click="toggle_cards" phx-value-id={{ @id }} phx-value-show_cards={{ !@show_cards }} class="is-clickable" >
            <span class="icon">
              <i :if={{ !@show_cards }} class="fas fa-eye"></i>
              <i :if={{ @show_cards }} class="fas fa-eye-slash"></i>
            </span>
          </span>
        </template>
      </Decklist>
    """
  end

  def toggle_cards(%{"id" => id, "show_cards" => show_cards}) do
    send_update(__MODULE__, id: id, show_cards: show_cards)
  end

  def toggle_cards(%{"id" => id}), do: toggle_cards(%{"id" => id, "show_cards" => false})
end
