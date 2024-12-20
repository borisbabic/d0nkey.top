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
        assigns = %{
          info: _info,
          deck: _deck,
          legend_rank: _,
          streamer_deck_path: _sdp
        }
      ) do
    ~F"""
      <div class="tag column" :if={is_integer(@info.peak)}>
        Peaked By: {@info.peaked_by}
      </div>
      <div :if={@legend_rank}> {@legend_rank} </div>
      <div class="tag column" :if={is_binary(@info.first_streamed_by)}>
        First Streamed: {@info.first_streamed_by}
      </div>
      <a href={@streamer_deck_path} class="tag column is-link" :if={@info.streamers && Enum.any?(@info.streamers)}>
        # Streamed: {@info.streamers |> Enum.count()}
      </a>
      <StreamingDeckNow deck={@deck}/>
    """
  end

  def render(%{deck_id: deck_id} = assigns) when is_integer(deck_id) do
    info = DeckStreamingInfoBag.get(deck_id)
    %{
      streamer_deck_path:
        Routes.streaming_path(BackendWeb.Endpoint, :streamer_decks, %{"deck_id" => deck_id}),
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
