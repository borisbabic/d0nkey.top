defmodule Backend.HearthstoneJson do
  @moduledoc false

  use GenServer
  @name :hearthstone_json
  alias Backend.Infrastructure.HearthstoneJsonCommunicator, as: Api
  alias Backend.HearthstoneJson.Card
  alias Backend.Hearthstone.Deck
  alias Backend.CardMatcher

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  @min_jaro_distance 0.85
  @spec closest_collectible(String.t(), number()) :: [{number(), Card.t()}]
  def closest_collectible(card_name, cutoff \\ @min_jaro_distance),
    do: collectible_cards() |> CardMatcher.match_name(card_name, cutoff)

  @spec closest(String.t(), number()) :: [{number(), Card.t()}]
  def closest(card_name, cutoff \\ @min_jaro_distance),
    do: cards() |> CardMatcher.match_name(card_name, cutoff)

  def get_card(dbf_id), do: table() |> Util.ets_lookup("card_#{dbf_id}")

  @spec get_fresh() :: [Card]
  def get_fresh() do
    case Api.get_cards() do
      {:ok, cards} ->
        cards

      _ ->
        Process.send_after(self(), :update_cards, 20_000)
        get_json()
    end
  end

  def update_cards() do
    GenServer.cast(@name, {:update_cards})
  end

  def update_cards(cards) do
    GenServer.cast(@name, {:update_cards, cards})
  end

  @spec get_json() :: [Card]
  defp get_json() do
    with {:ok, body} <- File.read("lib/data/collectible.json"),
         {:ok, json} <- body |> Poison.decode() do
      json |> Enum.map(&Card.from_raw_map/1)
    end
  end

  def init(args \\ [fetch_fresh: false]) do
    table = :ets.new(@name, [:named_table])
    state = %{table: table, fetch_fresh: args[:fetch_fresh]}

    # init with json
    # get
    state
    |> Map.put(:fetch_fresh, false)
    |> update_table()

    update_cards()
    {:ok, state}
  end

  @spec canonical_id(integer() | String.t()) :: integer() | any()
  def canonical_id(dbf_id),
    do: Util.ets_lookup(table(), "canonical_id_#{to_string(dbf_id)}", dbf_id)

  @spec tile_url(Card.t() | String.t()) :: String.t()
  def tile_url(%{id: id}), do: tile_url(id)
  def tile_url(id), do: "https://art.hearthstonejson.com/v1/tiles/#{id}.png"

  @spec card_url(Card.t() | String.t()) :: String.t()
  def card_url(card), do: card_url(card, :"256x")

  @spec tile_card_url(Card.t() | integer()) :: {String.t(), String.t()}
  def tile_card_url(dbf_id) when is_integer(dbf_id), do: get_card(dbf_id) |> tile_card_url

  def tile_card_url(card = %{id: id}) when is_binary(id) do
    {
      tile_url(card),
      card_url(card)
    }
  end

  def tile_card_url(_), do: {nil, nil}

  @spec card_url(Card.t() | String.t(), :"256x" | :"512x") :: String.t()
  def card_url(%{id: id}, size), do: card_url(id, size)

  def card_url(id, size),
    do: "https://art.hearthstonejson.com/v1/render/latest/enUS/#{size}/#{id}.png"

  def update_table(%{table: table, fetch_fresh: false}), do: get_json() |> update_table(table)
  def update_table(%{table: table, fetch_fresh: true}), do: get_fresh() |> update_table(table)

  def update_table(_cards, :undefined), do: nil

  def update_table(cards, table) do
    cards
    |> Enum.each(fn c ->
      :ets.insert(table, {"card_#{c.dbf_id}", c})
      :ets.insert(table, {"card_class_#{c.dbf_id}", c.card_class})
    end)

    collectible_cards = Enum.filter(cards, & &1.collectible)
    insert_canonical_ids(table, collectible_cards)

    :ets.insert(table, {"all_cards", cards})
    :ets.insert(table, {"collectible_cards", collectible_cards})
    :ets.insert(table, {"playable_cards", cards |> Enum.filter(&Card.playable?/1)})
  end

  @canonical_set_priority [
    # core year of the hydra, 2022
    1810,
    "CORE"
  ]
  defp insert_canonical_ids(table, collectible_cards) do
    collectible_cards
    |> Enum.group_by(&Card.group_by/1)
    |> Enum.map(&elem(&1, 1))
    |> Enum.filter(fn cards ->
      Enum.any?(cards, &(&1.set in @canonical_set_priority))
    end)
    |> Enum.each(&insert_canonical_group(table, &1))
  end

  defp insert_canonical_group(table, cards) do
    non_classic =
      cards
      # skip if classic mode card
      |> Enum.filter(&(&1.set != "VANILLA"))

    with %{dbf_id: canonical_id} <- find_canonical(non_classic) do
      Enum.each(non_classic, fn %{dbf_id: dbf_id} ->
        if dbf_id != canonical_id do
          :ets.insert(table, {"canonical_id_#{dbf_id}", canonical_id})
        end
      end)
    end
  end

  defp find_canonical(cards) do
    Enum.find_value(@canonical_set_priority, fn set ->
      Enum.find(cards, &(&1.set == set))
    end)
  end

  def get_class(dbf_id) do
    table()
    |> Util.ets_lookup("card_class_#{dbf_id}")
  end

  def table(), do: :ets.whereis(@name)

  @doc """
  If the hero isn't available then it defaults to the basic hero for the class
  """
  @spec get_hero(Deck.t()) :: Backend.HearthstoneJson.Card.t()
  def get_hero(deck) do
    deck.hero
    |> get_card()
    |> case do
      nil ->
        deck.class
        |> Deck.get_basic_hero()
        |> get_card()

      hero ->
        hero
    end
  end

  def cards(), do: table() |> Util.ets_lookup("all_cards", [])
  def collectible_cards(), do: table() |> Util.ets_lookup("collectible_cards", [])
  def playable_cards(), do: table() |> Util.ets_lookup("playable_cards", [])

  def handle_cast({:update_cards, cards}, state = %{table: table}) do
    update_table(cards, table)
    {:noreply, state}
  end

  def handle_cast({:update_cards}, state) do
    update_table(state)
    {:noreply, state}
  end

  def handle_info(:update_cards, state) do
    update_table(state)
    {:noreply, state}
  end

  def up?(), do: GenServer.whereis(@name) != nil
end
