defmodule Backend.Hearthstone.CardBag do
  @moduledoc "Contains in memory cache for cards"

  use GenServer
  alias Backend.Hearthstone.Card
  @name :hearthstone_card_bag
  @ten_hours 36_000_000
  @five_min 300_000
  @get_cards_opts %{collectible: "0,1"}

  def tile_card_url(card_id) do
    case card(card_id) do
      %{crop_image: crop_image, image: image} ->
        {crop_image, image}

      _ ->
        {nil, nil}
    end
  end

  @spec card(String.t() | integer()) :: Card.t() | nil
  def card(card_id), do: Util.ets_lookup(table(), "card_id_#{card_id}")

  @spec all() :: [Card.t()]
  def all() do
    :ets.match_object(table(), {:_, :"$1"})
  end

  ##### /Public Api

  def refresh_table(), do: GenServer.cast(@name, :refresh_table)

  def update(after_ms \\ 0) do
    GenServer.cast(@name, {:send_loop, after_ms})
  end

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    table = :ets.new(@name, [:named_table])

    send_loop(@five_min)
    {:ok, %{table: table, last_success_response: nil}, {:continue, :init}}
  end

  def handle_continue(:init, state = %{table: table}) do
    set_table(table)
    {:noreply, state}
  end

  def handle_cast({:send_loop, after_ms}, state) do
    send_loop(after_ms)
    {:noreply, state}
  end

  def handle_cast(:refresh_table, state = %{table: table}) do
    set_table(table)
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
    case Hearthstone.Api.next_page(prev_response, @get_cards_opts) do
      {:ok, response = %{cards: cards = [_ | _]}} ->
        Task.start(fn ->
          Backend.Hearthstone.upsert_cards(cards)
        end)

        table
        |> do_update_table(response)

      {:error, :already_at_last_pag} ->
        set_table(table)
        :ok

      _ ->
        set_table(table)
        {:error, prev_response}
    end
  end

  @spec set_cards(reference(), [Card.t()]) :: reference()
  defp set_cards(table, cards) do
    cards
    |> Enum.each(fn card ->
      :ets.insert(table, {"card_id_#{card.id}", card})
    end)

    table
  end

  defp set_table(table) do
    cards = Backend.Hearthstone.all_cards()
    set_cards(table, cards)
  end

  defp send_loop(after_ms), do: Process.send_after(self(), :loop, after_ms)

  defp table(), do: :ets.whereis(@name)
end
