defmodule Backend.Streaming.StreamerDeckBag do
  @moduledoc false
  use GenServer

  alias Backend.Streaming
  alias Backend.Streaming.Streamer
  alias Backend.Streaming.StreamerDeck

  @supported_criteria ["twitch_login", "twitch_id"]
  @max_length 50
  @base_criteria [{"limit", @max_length}, {"order_by", {:desc, :last_played}}]
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(_args) do
    table = :ets.new(__MODULE__, [:named_table])
    {:ok, %{table: table}}
  end

  def log(streamer_deck) do
    GenServer.cast(__MODULE__, {:log, streamer_deck})
  end

  def handle_cast({:log, streamer_deck}, state = %{table: table}) do
    update_overall(streamer_deck, table)
    update_per_streamer(streamer_deck, table)
    {:noreply, state}
  end

  defp update_per_streamer(streamer_deck, table) do
    new =
      get_or_fetch(streamer_deck, table)
      |> add(streamer_deck)

    for key <- all_keys(streamer_deck) do
      :ets.insert(table, {key, new})
    end
  end

  defp update_overall(streamer_deck, table) do
    new =
      get_or_fetch(table)
      |> add(streamer_deck)

    :ets.insert(table, {:all_streamers, new})
  end

  defp add(list, new) do
    [new | list]
    |> sort()
    |> Enum.uniq_by(fn
      %{deck: %{id: deck_id}, streamer: %{id: streamer_id}} ->
        "deck_id_#{deck_id}_streamer_id_#{streamer_id}"

      _ ->
        Ecto.UUID.generate()
    end)
    |> Enum.take(@max_length)
  end

  defp sort(list), do: Enum.sort_by(list, & &1.last_played, {:desc, NaiveDateTime})

  defp get_or_fetch(%{streamer: streamer}, table), do: get_or_fetch(streamer, table)

  defp get_or_fetch(streamer, table) do
    with {:ok, key} <- key(streamer),
         [_ | _] = result <- Util.ets_lookup(table, key, :not_cached) do
      result
    else
      :not_cached ->
        [{"twitch_id", streamer.twitch_id} | @base_criteria] |> Streaming.streamer_decks()

      _ ->
        []
    end
  end

  defp get_or_fetch(table) do
    case Util.ets_lookup(table, :all_streamers) do
      nil -> Backend.Streaming.streamer_decks(@base_criteria)
      sd -> sd
    end
  end

  defp key(key) when is_binary(key), do: {:ok, key}
  defp key(%{twitch_id: twitch_id}), do: {:ok, "twitch_id_#{twitch_id}"}

  defp key([{criteria, value}]) when criteria in @supported_criteria,
    do: {:ok, "#{criteria}_#{value}"}

  defp key([]), do: {:ok, :all_streamers}
  defp key(_), do: :error

  defp all_keys(%StreamerDeck{streamer: streamer}), do: all_keys(streamer)

  defp all_keys(%Streamer{twitch_id: twitch_id} = streamer) do
    by_id = "twitch_id_#{twitch_id}"

    case Streamer.twitch_login(streamer) do
      login when is_binary(login) -> [by_id, "twitch_login_#{login}"]
      _ -> [by_id]
    end
  end

  defp all_keys(_), do: []
  def supports?(criteria) when is_map(criteria), do: criteria |> Enum.to_list() |> supports?()
  def supports?([]), do: true
  def supports?([{criteria, _}]) when criteria in @supported_criteria, do: true
  def supports?(_), do: false

  def streamer_decks(criteria) when is_map(criteria),
    do: criteria |> Enum.to_list() |> streamer_decks()

  def streamer_decks(criteria) do
    if supports?(criteria) do
      get(criteria) |> Util.bangify()
    else
      Streaming.streamer_decks(criteria)
    end
  end

  def get(criteria) when is_map(criteria), do: criteria |> Enum.to_list() |> get()

  def get(criteria) do
    with true <- supports?(criteria),
         {:ok, key} <- key(criteria),
         sd when sd != :not_set <- Util.ets_lookup(table(), key, :not_set) do
      {:ok, sd}
    else
      false -> {:error, :unsupported_criteria}
      :error -> {:error, :couldnt_create_key}
      :not_set -> GenServer.call(__MODULE__, {:init, criteria})
    end
  end

  def handle_call({:init, criteria}, _from, %{table: table} = state) do
    {:reply, init(criteria, table), state}
  end

  defp init(base_criteria, table) do
    with {:ok, merged} <- merge_base(base_criteria),
         {:ok, key} <- key(base_criteria),
         {:ok, fetched} <- upstream(merged),
         true <- :ets.insert(table, {key, fetched}) do
      {:ok, fetched}
    end
  end

  defp merge_base(criteria) when is_list(criteria),
    do: {:ok, (@base_criteria ++ criteria) |> Map.new()}

  defp merge_base(criteria) when is_map(criteria), do: Enum.to_list(criteria) |> merge_base()
  defp merge_base(_), do: {:error, :unsupported_criteria}

  defp upstream(criteria), do: {:ok, Streaming.streamer_decks(criteria)}

  def table(), do: :ets.whereis(__MODULE__)
end
