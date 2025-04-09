defmodule FunctionComponents.DeckComponents do
  @moduledoc false

  use BackendWeb, :component
  alias Backend.Hearthstone.Deck
  attr :archetype, :any, required: true

  def archetype(assigns) do
    ~H"""
      <div class={"decklist-info deck-title #{Deck.extract_class(@archetype) |> String.downcase()}"}>
        <a class="basic-black-text deck-title" href={~p"/archetype/#{@archetype}"}>
          <%= @archetype %>
        </a>
      </div>
    """
  end
end
