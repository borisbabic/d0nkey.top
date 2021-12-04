defmodule Backend.Hearthstone.CardBag do
  @moduledoc "Contains in memory cache for cards"

  use GenServer
  @name :hearthstone_card_bag
  @ten_hours 36_000_000
  @five_min 300_000

  def tile_card_url(card_id) do
    # {Backend.HearthstoneJson.tile_url(card_id), Backend.HearthstoneJson.card_url(card_id)}
    case card(card_id) do
      %{crop_image: crop_image, image: %{"en_us" => image}} ->
        {crop_image, image}

      _ ->
        {nil, nil}
    end
  end

  def raw_response(), do: Util.ets_lookup(table(), :raw_response)

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    table = :ets.new(@name, [:named_table])

    send_loop(0)
    {:ok, %{table: table, last_success_response: nil}}
  end

  def handle_cast({:send_loop, after_ms}, state) do
    send_loop(after_ms)
    {:noreply, state}
  end

  def handle_info(:loop, state = %{table: table, last_success_response: prev_response}) do
    last_success =
      case do_update_table(table, prev_response) do
        {:error, last_success} ->
          send_loop(@five_min)
          last_success

        :ok ->
          send_loop(@ten_hours)
          nil
      end

    new_state = Map.put(state, :last_success_response, last_success)

    {:noreply, new_state}
  end

  defp do_update_table(table, prev_response) do
    case Hearthstone.Api.next_page(prev_response) do
      {:ok, response = %{cards: cards}} ->
        table
        |> set_cards(cards)
        |> do_update_table(response)

      {:error, :already_at_last_pag} ->
        :ok

      _ ->
        {:error, prev_response}
    end
  end

  defp set_cards(table, cards) do
    cards
    |> Enum.each(fn card ->
      :ets.insert(table, {"card_id_#{card.id}", card})
    end)

    table
  end

  def card(card_id), do: Util.ets_lookup(table(), "card_id_#{card_id}")

  def update(after_ms \\ 0) do
    GenServer.cast(@name, {:send_loop, after_ms})
  end

  defp send_loop(after_ms), do: Process.send_after(self(), :loop, after_ms)

  defp table(), do: :ets.whereis(@name)
end
