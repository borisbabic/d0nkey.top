defmodule Components.DeckAdmin do
  @moduledoc "Actions for admining decks"

  use BackendWeb, :surface_live_component

  alias Backend.UserManager.User
  alias Hearthstone.Enums.Format
  alias Backend.Hearthstone
  alias Backend.Hearthstone.DeckDeduplicator
  prop(deck, :any, required: true)
  prop(user, :any, required: true)

  def render(assigns) do
    ~F"""
      <div class="tw-inline-flex tw-flex-wrap tw-items-center tw-gap-1.5">
        <button
          class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-slate-800/90 hover:tw-bg-slate-700 tw-text-slate-300 hover:tw-text-white tw-border tw-border-slate-700/80 hover:tw-border-slate-600 tw-transition-colors tw-cursor-pointer"
          :if={target = format_to_swap(@deck)}
          :on-click="change_format"
          phx-value-format={target}
        >
          To {Format.name(target)}
        </button>
        <button
          class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-slate-800/90 hover:tw-bg-slate-700 tw-text-slate-300 hover:tw-text-white tw-border tw-border-slate-700/80 hover:tw-border-slate-600 tw-transition-colors tw-cursor-pointer"
          :if={1 < (Hearthstone.get_same(@deck) |> Enum.count())}
          :on-click="enqueue_duplicates"
        >
          Deduplicate
        </button>
        <button
          class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-slate-800/90 hover:tw-bg-slate-700 tw-text-slate-300 hover:tw-text-white tw-border tw-border-slate-700/80 hover:tw-border-slate-600 tw-transition-colors tw-cursor-pointer"
          :on-click="recalculate_archetype"
        >
          Rearchetype
        </button>
      </div>
    """
  end

  def handle_event("recalculate_archetype", _, %{assigns: %{deck: deck}} = socket) do
    deck = Hearthstone.check_archetype(deck)
    {:noreply, socket |> assign(deck: deck)}
  end

  def handle_event("change_format", %{"format" => format}, %{assigns: %{deck: deck}} = socket) do
    {:ok, deck} = Hearthstone.change_format(deck, format)
    {:noreply, socket |> assign(deck: deck)}
  end

  def handle_event("enqueue_duplicates", _, %{assigns: %{deck: %{id: id}}} = socket) do
    DeckDeduplicator.enqueue_duplicates_for_deck_ids([id])
    {:noreply, socket}
  end

  def format_to_swap(%{format: 1}), do: 2
  def format_to_swap(%{format: 2}), do: 1
  def format_to_swap(_), do: nil

  def can_admin?(user), do: User.can_access?(user, "deck")
end
