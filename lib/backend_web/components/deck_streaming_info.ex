defmodule Components.DeckStreamingInfo do
  @moduledoc false
  use Surface.Component
  use BackendWeb.ViewHelpers
  alias Components.StreamingDeckNow
  alias BackendWeb.Router.Helpers, as: Routes
  alias Backend.Streaming.DeckStreamingInfoBag
  prop(deck_id, :integer, required: true)

  def render(
        assigns = %{
          info: %{
            peak: peak,
            peaked_by: pb,
            streamers: s,
            first_streamed_by: fsb
          },
          deck: deck,
          streamer_decks_path: sdp
        }
      ) do
    legend_rank = render_legend_rank(peak)

    ~F"""
      <div class="tag column" :if={is_integer(peak)}>
        Peaked By: {pb}
      </div>
      <div :if={legend_rank}> {legend_rank} </div>
      <div class="tag column" if:={is_binary(fsb)}>
        First Streamed: {fsb}
      </div>
      <a href={"#{sdp}"} class="tag column is-link" if:= {s && Enum.any?(s)}>
        # Streamed: {s |> Enum.count()}
      </a>
      <StreamingDeckNow deck={deck}/>

    """
  end

  def render(%{deck_id: deck_id, socket: socket}) when is_integer(deck_id) do
    %{
      streamer_deck_path:
        Routes.streaming_path(BackendWeb.Endpoint, :streamer_decks, %{"deck_id" => deck_id}),
      deck: Backend.Hearthstone.deck(deck_id),
      socket: socket,
      info: DeckStreamingInfoBag.get(deck_id)
    }
    |> render()
  end

  def render(assigns),
    do: ~F"""
    """

  def create_info(_), do: %{}
end
