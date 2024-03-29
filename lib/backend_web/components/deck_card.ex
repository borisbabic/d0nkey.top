defmodule Components.DeckCard do
  @moduledoc false
  use Surface.Component
  slot(before_deck, required: false)
  slot(default, required: true)
  slot(after_deck, required: true)
  prop(after_deck_class, :css_class, default: "columns is-multiline is-mobile is-text-overflow")

  def render(assigns) do
    ~F"""
    <div class="card" style="width: calc(var(--decklist-width) + 15px);">
      <div class="columns is-multiline is-mobile is-text-overflow" style="margin:7.5px">
        <#slot {@before_deck} />
      </div>
      <div class="card-image" style="margin:7.5px;">
        <#slot />
      </div>
      <div class={@after_deck_class} style="margin:7.5px">
        <#slot {@after_deck} />
      </div>
    </div>
    """
  end
end
