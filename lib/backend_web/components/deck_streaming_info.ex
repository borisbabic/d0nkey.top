defmodule Components.DeckStreamingInfo do
  @moduledoc false
  use Surface.Component
  alias Backend.Streaming
  alias Components.StreamingDeckNow
  use BackendWeb.ViewHelpers
  alias BackendWeb.Router.Helpers, as: Routes
  prop(deck_id, :integer, required: true)

  def render(
        assigns = %{
          peak: peak,
          peaked_by: pb,
          streamers: s,
          first_streamed_by: fsb,
          deck: deck,
          streamer_decks_path: sdp
        }
      ) do
    legend_rank = render_legend_rank(peak)

    ~F"""
      <div class="tag column" :if={pb}>
        Peaked By: {pb}
      </div>
      <div :if={legend_rank}> {legend_rank} </div>
      <div class="tag column" if:={fsb}>
        First Streamed: {fsb}
      </div>
      <a href={"#{sdp}"} class="tag column is-link" if:= {s}>
        # Streamed: {s |> Enum.count()}
      </a>
      <StreamingDeckNow deck={deck}/>

    """
  end

  def render(%{deck_id: deck_id, socket: socket}) when is_integer(deck_id) do
    deck_id
    |> Streaming.streamer_decks_by_deck()
    |> create_info()
    |> Map.put(
      :streamer_decks_path,
      Routes.streaming_path(BackendWeb.Endpoint, :streamer_decks, %{"deck_id" => deck_id})
    )
    |> Map.put(:deck, Backend.Hearthstone.deck(deck_id))
    |> Map.put(:socket, socket)
    |> render()
  end

  def render(assigns),
    do: ~F"""
    """

  def create_info(sd) when length(sd) > 0 do
    {peak, peaked_by} =
      sd
      |> Enum.filter(&(&1.best_legend_rank > 0))
      |> case do
        [] ->
          {nil, nil}

        filtered ->
          peak_sd = filtered |> Enum.min_by(& &1.best_legend_rank)
          {peak_sd.best_legend_rank, peak_sd |> name()}
      end

    first_played = sd |> Enum.min_by(&(&1.inserted_at |> NaiveDateTime.to_iso8601()))

    %{
      peak: peak,
      peaked_by: peaked_by,
      streamers: sd |> Enum.map(&name/1),
      first_streamed_by: first_played |> name()
    }
  end

  def create_info(_), do: %{}

  defp name(%{streamer: streamer}), do: streamer |> Backend.Streaming.Streamer.twitch_display()
end
