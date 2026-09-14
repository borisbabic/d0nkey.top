defmodule Components.DeckStreamingInfo do
  @moduledoc false
  use Surface.Component
  use BackendWeb.ViewHelpers
  alias Components.StreamingDeckNow
  alias BackendWeb.Router.Helpers, as: Routes
  alias Backend.Streaming.DeckStreamingInfoBag
  prop(deck_id, :integer, required: true)
  data(info, :any)
  data(deck, :any)
  data(streamer_deck_path, :any)
  data(legend_rank, :any)

  def render(
        %{
          info: _info,
          deck: _deck,
          legend_rank: _,
          streamer_deck_path: _sdp
        } = assigns
      ) do
    ~F"""
      <div
        class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-amber-500/15 tw-text-amber-400 tw-border tw-border-amber-500/30"
        :if={is_integer(@info.peak)}
        title={"Peaked by #{@info.peaked_by}"}
      >
        <svg class="tw-w-3 tw-h-3 tw-text-amber-400 tw-shrink-0" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
        </svg>
        <span class="tw-truncate tw-max-w-[130px]">Peak: {@info.peaked_by}</span>
      </div>
      <div :if={@legend_rank}> {@legend_rank} </div>
      <div
        class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-medium tw-bg-slate-800/90 tw-text-slate-300 tw-border tw-border-slate-700/60"
        :if={is_binary(@info.first_streamed_by)}
        title={"First streamed by #{@info.first_streamed_by}"}
      >
        <svg class="tw-w-3 tw-h-3 tw-text-slate-400 tw-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"/>
        </svg>
        <span class="tw-truncate tw-max-w-[130px]">1st: {@info.first_streamed_by}</span>
      </div>
      <a
        href={@streamer_deck_path}
        class="tw-inline-flex tw-items-center tw-gap-1 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-sky-500/15 hover:tw-bg-sky-500/25 tw-text-sky-400 tw-border tw-border-sky-500/30 tw-transition-colors"
        :if={@info.streamers && Enum.any?(@info.streamers)}
        title={"Streamed by #{Enum.count(@info.streamers)} streamers"}
      >
        <svg class="tw-w-3 tw-h-3 tw-text-sky-400 tw-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
        </svg>
        <span>Streamed: {Enum.count(@info.streamers)}</span>
      </a>
      <StreamingDeckNow deck={@deck}/>
    """
  end

  def render(%{deck_id: deck_id} = assigns) when is_integer(deck_id) do
    info = DeckStreamingInfoBag.get(deck_id)

    %{
      streamer_deck_path: Routes.streaming_path(BackendWeb.Endpoint, :streamer_decks, %{"deck_id" => deck_id}),
      deck: Backend.Hearthstone.deck(deck_id),
      info: info,
      legend_rank: info |> Map.get(:peak) |> render_legend_rank()
    }
    |> Map.merge(assigns)
    |> render()
  end

  def render(assigns) do
    ~F"""
    """
  end

  def create_info(_), do: %{}
end
