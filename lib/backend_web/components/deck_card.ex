defmodule Components.DeckCard do
  @moduledoc false
  use Surface.Component
  slot(before_deck, required: false)
  slot(default, required: true)
  slot(after_deck, required: true)
  prop(after_deck_class, :css_class, default: "columns is-multiline is-mobile is-text-overflow")
  prop(class, :css_class, default: nil)

  def render(assigns) do
    ~F"""
    <div
      class={[
        "card tw-relative tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-xl tw-shadow-xl hover:tw-border-slate-600/80 hover:tw-z-20 tw-transition-all tw-duration-200",
        @class
      ]}
      style="width: calc(var(--decklist-width) + 15px);"
    >
      <div :if={slot_assigned?(:before_deck)} class="columns is-multiline is-mobile is-text-overflow" style="margin:7.5px">
        <#slot {@before_deck} />
      </div>
      <div class="card-image" style="margin:7.5px;">
        <#slot />
      </div>
      <div :if={slot_assigned?(:after_deck)} class={@after_deck_class} style="margin:7.5px">
        <#slot {@after_deck} />
      </div>
    </div>
    """
  end
end
