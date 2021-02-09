defmodule Components.DeckStreamingInfo do
  @moduledoc false
  use Surface.Component
  alias Backend.Streaming
  use BackendWeb.ViewHelpers
  alias BackendWeb.Router.Helpers, as: Routes
  prop(deck_id, :integer, required: true)

  def render(%{deck_id: deck_id}) when is_integer(deck_id) do
    deck_id
    |> Streaming.streamer_decks_by_deck()
    |> create_info()
    |> Map.put(
      :streamer_decks_path,
      Routes.streaming_path(BackendWeb.Endpoint, :streamer_decks, %{"deck_id" => deck_id})
    )
    |> render()
  end

  def render(
        assigns = %{
          peak: peak,
          peaked_by: pb,
          streamers: s,
          first_streamed_by: fsb,
          streamer_decks_path: sdp
        }
      ) do
    legend_rank = render_legend_rank(peak)

    ~H"""
    <div class="columns is-multiline is-mobile is-text-overflow" style="margin:7.5px">
      <div class="tag column" :if={{ pb }}>
        Peaked By: {{ pb }}
      </div>
      <div :if={{ legend_rank }}> {{ legend_rank }} </div>
      <div class="tag column" if:={{ fsb }}>
        First Streamed: {{ fsb }}
      </div>
      <a href="{{ sdp }}" class="tag column is-link" if:= {{ s }}>
        # Streamers: {{ s |> Enum.count() }}
      </a>
    </div>

    """
  end

  def render(_), do: ""

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
