defmodule Backend.Streaming.DeckStreamingInfoBag do
  @moduledoc false
  use GenServer
  alias Backend.Streaming.DeckStreamingInfo
  alias Backend.Streaming.Streamer
  alias Backend.Streaming

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(_args) do
    table = :ets.new(__MODULE__, [:named_table])
    {:ok, %{table: table}}
  end

  def get(id) do
    with nil <- get_fresh(id) do
      update(id)
    end
  end

  def update(deck_id) do
    deck_id
    |> Streaming.streamer_decks_by_deck()
    |> create_info()
    |> set_info(deck_id)
  end

  def get_fresh(id) do
    with {cached, info} <- table() |> Util.ets_lookup(id),
         true <- fresh?(cached) do
      info
    else
      _ -> nil
    end
  end

  defp create_info(sd) when length(sd) > 0 do
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

    %DeckStreamingInfo{
      peak: peak,
      peaked_by: peaked_by,
      streamers: sd |> Enum.map(&name/1),
      first_streamed_by: first_played |> name()
    }
  end

  defp create_info(_), do: DeckStreamingInfo.empty()

  defp name(%{streamer: streamer}), do: streamer |> Streamer.twitch_display()
  defp name(%Streamer{} = streamer), do: streamer |> Streamer.twitch_display()

  defp set_info(info, deck_id) do
    GenServer.call(__MODULE__, {:set_info, info, deck_id})
  end

  def handle_call({:set_info, info, deck_id}, _, state = %{table: table}) do
    now = NaiveDateTime.utc_now()
    :ets.insert(table, {deck_id, {now, info}})
    {:reply, info, state}
  end

  def fresh?(date) do
    cutoff =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-1 * 60 * 30)

    :gt == NaiveDateTime.compare(date, cutoff)
  end

  def table(), do: :ets.whereis(__MODULE__)
end
