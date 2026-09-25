defmodule Components.DeckTableRow do
  @moduledoc """
  A concise table row representing a single deck with its cards displayed horizontally left-to-right,
  stats (winrate, games, turns, duration, dust), archetype/class info, and deck copying.
  """

  use BackendWeb, :surface_component
  alias Components.DeckCardsHorizontalRow
  alias Components.WinrateTag
  alias Backend.Hearthstone.Deck

  prop(id, :string, required: true)
  prop(deck_with_stats, :map, required: true)
  prop(show_win_loss?, :boolean, default: false)
  prop(user, :any, default: nil)
  prop(card_mode, :string, default: "card_top")

  data(deck, :any)
  data(total, :any)
  data(winrate, :any)
  data(win_loss, :any)
  data(turns, :any)
  data(duration, :any)

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

    assigns =
      assigns
      |> assign(
        deck: deck,
        total: total,
        winrate: winrate,
        win_loss: win_loss,
        turns: turns,
        duration: duration
      )

    ~F"""
    <tr id={@id} class="tw-border-b tw-border-slate-800/80 tw-transition-colors hover:tw-bg-slate-800/20">
      <td class="tw-px-4 tw-py-3">
        <DeckCardsHorizontalRow
          deck={@deck}
          user={@user}
          card_mode={@card_mode}
          header_class="tw-flex tw-items-center tw-mb-2.5"
          info_class="tw-w-72 tw-shrink-0 tw-flex tw-items-center tw-gap-2.5 tw-pl-4 tw-pr-4 tw-min-w-0"
        >
          <:left>
            <div class="tw-w-24 tw-shrink-0 tw-flex tw-justify-center">
              <WinrateTag :if={@winrate} winrate={@winrate} win_loss={@win_loss} class="tag" />
            </div>
          </:left>
          <:right>
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
          </:right>
        </DeckCardsHorizontalRow>
      </td>
    </tr>
    """
  end

  defp get_deck(%{deck: %Deck{} = deck}), do: deck
  defp get_deck(%{deck: deck}) when is_map(deck) or is_nil(deck), do: deck
  defp get_deck(%{deck_id: deck_id}) when is_integer(deck_id), do: Backend.Hearthstone.deck(deck_id)
  defp get_deck(_), do: nil

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
end
