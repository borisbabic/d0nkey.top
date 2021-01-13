defmodule Components.DeckStreamingInfo do
  @moduledoc false
  use Surface.Component
  alias Backend.Streaming
  prop(deck_id, :integer, required: true)

  def render(%{deck_id: deck_id}) when is_integer(deck_id) do
    deck_id
    |> Streaming.streamer_decks_by_deck()
    |> create_info()
    |> render()
  end

  def render(assigns = %{peak: peak, peaked_by: pb, streamers: s}) do
    ~H"""
    <div >
      <div class="tag is-success" :if={{ peak }}>
        peak: {{ peak }}
      </div>
        <br>
      <div class="tag is-success" :if={{ pb }}>
        peaked_by: {{ pb }}
      </div>
        <br>
      <div class="tag">
        streamers: {{ s |> Enum.count() }}
      </div>
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
      streamers: sd |> Enum.map(&name/1)
    }
  end

  defp name(%{streamer: streamer}), do: streamer |> Backend.Streaming.Streamer.twitch_display()
end
