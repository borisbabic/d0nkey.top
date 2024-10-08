defmodule Backend.Hearthstone.CardBag do
  @moduledoc "Contains in memory cache for cards"

  use GenServer
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Card
  alias Backend.CardMatcher
  @name :hearthstone_card_bag

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

  defp all() do
    :ets.match_object(table(), {:_, :"$1"})
  end

  ##### /Public Api

  @doc """
  Collectible cards sorted by standard first
  """
  def standard_first() do
    Util.ets_lookup(table(), :standard_first, [])
  end

  defp order_by_standard(cards) do
    standard = Backend.Hearthstone.standard_card_sets() |> MapSet.new()

    (cards || [])
    |> Enum.sort_by(
      fn
        %{card_set: %{slug: slug}} -> MapSet.member?(standard, slug)
        _ -> false
      end,
      :desc
    )
  end

  @spec all_cards() :: [Card.t()] | Stream.t()
  def all_cards() do
    all()
    |> Stream.filter(fn
      {"card_id_" <> _, _} -> true
      _ -> false
    end)
    |> Stream.map(&elem(&1, 1))
  end

  def refresh_table(), do: GenServer.cast(@name, :refresh_table)

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    table = :ets.new(@name, [:named_table])

    {:ok, %{table: table, last_success_response: nil}, {:continue, :init}}
  end

  def handle_continue(:init, state = %{table: table}) do
    set_table(table)
    {:noreply, state}
  end

  def handle_cast(:refresh_table, state = %{table: table}) do
    set_table(table)
    {:noreply, state}
  end

  @spec set_cards(reference(), [Card.t()]) :: reference()
  defp set_cards(table, cards) do
    cards
    |> Enum.each(fn card ->
      :ets.insert(table, {"card_id_#{card.id}", card})
    end)

    table
  end

  defp set_deckcode_copy_id(table, cards) do
    for c <- cards do
      :ets.insert(table, {key_for_deckcode_copy_id(c.id), c.deckcode_copy_id || c.id})
    end
  end

  defp key_for_deckcode_copy_id(id), do: "deckcode_copy_id_#{id}"

  defp set_table(table) do
    cards = Hearthstone.all_cards()
    set_deckcode_copy_id(table, cards)
    set_cards(table, cards)

    standard_first =
      cards
      |> Enum.filter(& &1.collectible)
      |> order_by_standard()

    collectible_for_match =
      standard_first
      |> CardMatcher.prepare_for_match()

    :ets.insert(table, {:standard_first, standard_first})
    :ets.insert(table, {:collectible_for_match, collectible_for_match})
  end

  defp table(), do: :ets.whereis(@name)

  @min_distance 0.7
  @spec closest_collectible(String.t(), number()) :: [{number(), Card.t()}]
  def closest_collectible(card_name, cutoff \\ @min_distance) do
    Util.ets_lookup(table(), :collectible_for_match)
    |> CardMatcher.match_optimized(card_name, cutoff)
  end

  @spec deckcode_copy_id(integer()) :: integer()
  @doc "Find the id of the version of the card to use in copied deck codes"
  def deckcode_copy_id(id) do
    key = key_for_deckcode_copy_id(id)
    Util.ets_lookup(table(), key, id)
  end
end
