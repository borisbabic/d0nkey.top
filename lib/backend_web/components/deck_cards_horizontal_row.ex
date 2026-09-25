defmodule Components.DeckCardsHorizontalRow do
  @moduledoc """
  A single deck rendered as a compact header (class icon, deckcode copy, name, format, dust)
  followed by its full decklist laid out horizontally via `Components.DeckCardsHorizontal`.

  Shared by the decks table (`Components.DeckTableRow`, which adds winrate/game stats around
  it), the deck sheets page, and the deckviewer page.
  """

  use BackendWeb, :surface_component
  alias Components.DeckCardsHorizontal
  alias Backend.Hearthstone.Deck
  alias Backend.UserManager.User
  alias FunctionComponents.DeckComponents

  prop(deck, :map, required: true)
  prop(name, :string, default: nil)
  prop(user, :any, default: nil)
  prop(card_mode, :string, default: "card_top")
  prop(class, :string, default: "")
  prop(header_class, :string, default: "tw-flex tw-items-center tw-flex-wrap tw-gap-2 tw-mb-2")
  prop(info_class, :string, default: "tw-flex-1 tw-flex tw-items-center tw-gap-2.5 tw-min-w-0")

  data(class_slug, :string)

  slot(left)
  slot(right)

  def render(assigns) do
    deck = assigns[:deck]
    deck_class = if deck, do: Deck.class(deck), else: "NEUTRAL"
    class_slug = String.downcase(deck_class)

    assigns = assign(assigns, class_slug: class_slug)

    ~F"""
    <div class={["tw-w-full", @class]}>
      <div class={@header_class}>
        <#slot {@left} />
        <div class={@info_class}>
          <DeckComponents.class_icon class_slug={@class_slug} size={24} />
          <Components.Helper.deckcode_for_deck
            :if={@deck}
            deck={@deck}
            preferred_deckcode={User.preferred_deckcode(@user)}
          />
          <div class="tw-flex tw-flex-col tw-min-w-0">
            <a
              href={deck_link(@deck)}
              class="tw-font-bold tw-text-sm hover:tw-underline tw-text-slate-100 hover:tw-text-white tw-truncate"
            >
              {deck_display_name(@deck, @name)}
            </a>
            <div class="tw-flex tw-items-center tw-gap-1.5 tw-text-[11px] tw-text-slate-400">
              <span class="tw-uppercase tw-tracking-wide tw-font-semibold tw-text-[10px]">
                {format_label(@deck)}
              </span>
              <span :if={@deck && @deck.cost} class="tw-flex tw-items-center tw-gap-0.5 tw-text-amber-400/90" title="Crafting Dust">
                <span>✦</span> {format_number(@deck.cost)}
              </span>
            </div>
          </div>
        </div>
        <#slot {@right} />
      </div>
      <div :if={@deck} class="tw-overflow-x-auto tw-py-0.5">
        <DeckCardsHorizontal deck={@deck} size="md" wrap={false} mode={@card_mode} />
      </div>
    </div>
    """
  end

  defp deck_display_name(nil, _name), do: "Unknown Deck"
  defp deck_display_name(_deck, name) when is_binary(name) and name != "", do: name
  defp deck_display_name(deck, _name), do: Deck.name(deck) || Deck.class_name(deck)

  defp deck_link(nil), do: "#"

  defp deck_link(deck) do
    case Deck.archetype(deck) do
      nil -> Deck.link(deck)
      archetype -> ~p"/archetype/#{archetype}"
    end
  end

  defp format_label(nil), do: ""

  defp format_label(deck) do
    case Deck.format_name(deck) do
      name when is_binary(name) -> name
      _ -> ""
    end
  end

  defp format_number(nil), do: "-"
  defp format_number(n) when is_integer(n), do: Util.delimit_integer(n)
  defp format_number(n), do: to_string(n)
end
