defmodule Components.DeckTableRow do
  @moduledoc """
  A concise table row representing a single deck with its cards displayed horizontally left-to-right,
  stats (winrate, games, turns, duration, dust), archetype/class info, and deck copying.
  """

  use BackendWeb, :surface_component
  alias Components.DeckCardsHorizontal
  alias Components.WinrateTag
  alias Backend.Hearthstone.Deck
  alias Backend.UserManager.User
  alias Backend.UserManager.User.DecklistOptions
  alias FunctionComponents.DeckComponents

  prop(id, :string, required: true)
  prop(deck_with_stats, :map, required: true)
  prop(show_win_loss?, :boolean, default: false)
  prop(user, :map, default: nil)
  prop(card_mode, :string, default: "card_top")

  data(deck, :any)
  data(total, :any)
  data(winrate, :any)
  data(win_loss, :any)
  data(turns, :any)
  data(duration, :any)
  data(deck_class, :string)
  data(class_slug, :string)

  def render(assigns) do
    deck_with_stats = assigns[:deck_with_stats]
    deck = get_deck(deck_with_stats)
    total = Map.get(deck_with_stats, :total)
    winrate = Map.get(deck_with_stats, :winrate)
    turns = Map.get(deck_with_stats, :turns)
    duration = Map.get(deck_with_stats, :duration)

    win_loss =
      if assigns[:show_win_loss?] do
        %{wins: Map.get(deck_with_stats, :wins, 0), losses: Map.get(deck_with_stats, :losses, 0)}
      end

    deck_class = if deck, do: Deck.class(deck), else: "NEUTRAL"
    class_slug = String.downcase(deck_class)

    assigns =
      assigns
      |> assign(
        deck: deck,
        total: total,
        winrate: winrate,
        win_loss: win_loss,
        turns: turns,
        duration: duration,
        deck_class: deck_class,
        class_slug: class_slug
      )

    ~F"""
    <tr id={@id} class="tw-border-b tw-border-slate-800/80 tw-transition-colors hover:tw-bg-slate-800/20">
      <td class="tw-px-4 tw-py-3">
        <!-- 1. Top Meta Bar: Winrate, Deck Info & Additional Stats (All Left-Aligned) -->
        <div class="tw-flex tw-items-center tw-mb-2.5">
          <!-- Winrate (First Column) -->
          <div class="tw-w-24 tw-shrink-0 tw-flex tw-justify-center">
            <WinrateTag :if={@winrate} winrate={@winrate} win_loss={@win_loss} class="tag" />
          </div>

          <!-- Deck Info (Class Icon + Copy + Deck Name + Format + Dust) -->
          <div class="tw-w-72 tw-shrink-0 tw-flex tw-items-center tw-gap-2.5 tw-pl-4 tw-pr-4 tw-min-w-0">
            <DeckComponents.class_icon class_slug={@class_slug} size={24} />
            <Components.Helper.deckcode_for_deck
              :if={@deck}
              deck={@deck}
              preferred_deckcode={preferred_deckcode(@user)}
            />
            <div class="tw-flex tw-flex-col tw-min-w-0">
              <a
                href={deck_link(@deck)}
                class="tw-font-bold tw-text-sm hover:tw-underline tw-text-slate-100 hover:tw-text-white tw-truncate"
              >
                {deck_display_name(@deck)}
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

          <!-- Total Games -->
          <div class="tw-w-24 tw-shrink-0 tw-flex tw-flex-col tw-items-center">
            <span class="tw-font-bold tw-text-sm tw-text-slate-200">
              {format_number(@total)}
            </span>
            <span :if={@win_loss} class="tw-text-[11px] tw-text-slate-400">
              {@win_loss.wins}W - {@win_loss.losses}L
            </span>
            <span :if={!@win_loss} class="tw-text-[10px] tw-text-slate-500 tw-uppercase tw-tracking-wider">
              games
            </span>
          </div>

          <!-- Turns (Average Turns) -->
          <div class="tw-w-20 tw-shrink-0 tw-flex tw-flex-col tw-items-center">
            <span class="tw-font-bold tw-text-sm tw-text-slate-200">
              {format_turns(@turns)}
            </span>
            <span class="tw-text-[10px] tw-text-slate-500 tw-uppercase tw-tracking-wider">
              turns
            </span>
          </div>

          <!-- Duration (Average Duration) -->
          <div class="tw-w-24 tw-shrink-0 tw-flex tw-flex-col tw-items-center">
            <span class="tw-font-bold tw-text-sm tw-text-slate-200">
              {format_duration(@duration)}
            </span>
            <span class="tw-text-[10px] tw-text-slate-500 tw-uppercase tw-tracking-wider">
              duration
            </span>
          </div>
        </div>

        <!-- 2. Cards in its own dedicated row (full width) -->
        <div :if={@deck} class="tw-overflow-x-auto tw-py-0.5">
          <DeckCardsHorizontal deck={@deck} size="md" wrap={false} mode={@card_mode} />
        </div>
      </td>
    </tr>
    """
  end

  defp get_deck(%{deck: %Deck{} = deck}), do: deck
  defp get_deck(%{deck: deck}) when is_map(deck) or is_nil(deck), do: deck
  defp get_deck(%{deck_id: deck_id}) when is_integer(deck_id), do: Backend.Hearthstone.deck(deck_id)
  defp get_deck(_), do: nil

  defp deck_display_name(nil), do: "Unknown Deck"
  defp deck_display_name(deck), do: Deck.name(deck) || Deck.class_name(deck)

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

  defp format_turns(nil), do: "—"
  defp format_turns(turns) when is_number(turns), do: "#{Float.round(turns * 1.0, 1)}"
  defp format_turns(_), do: "—"

  defp format_duration(nil), do: "—"
  defp format_duration(0), do: "—"
  defp format_duration(+0.0), do: "—"

  defp format_duration(duration) when is_number(duration) do
    "#{Float.round(duration / 60.0, 1)}m"
  end

  defp format_duration(_), do: "—"

  defp preferred_deckcode(user),
    do: user |> User.decklist_options() |> DecklistOptions.preferred_deckcode()
end
