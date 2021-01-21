defmodule Backend.HearthstoneJson do
  @moduledoc false

  use GenServer
  @name :hearthstone_json
  alias Backend.Infrastructure.HearthstoneJsonCommunicator, as: Api
  alias Backend.HearthstoneJson.Card
  alias Backend.Hearthstone.Deck

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def get_card(dbf_id), do: table() |> Util.ets_lookup("card_#{dbf_id}")

  @spec get_fresh() :: [Card]
  def get_fresh() do
    Api.get_cards()
  end

  def update_cards() do
    GenServer.cast(@name, {:update_cards})
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
    if(args[:fetch_fresh], do: get_fresh(), else: get_json()) |> update_table(table)

    {:ok, %{table: table}}
  end

  @spec tile_url(Card.t() | String.t()) :: String.t()
  def tile_url(%{id: id}), do: tile_url(id)
  def tile_url(id), do: "https://art.hearthstonejson.com/v1/tiles/#{id}.png"

  @spec card_url(Card.t() | String.t()) :: String.t()
  def card_url(card), do: card_url(card, :"256x")

  @spec card_url(Card.t() | String.t(), :"256x" | :"512x") :: String.t()
  def card_url(%{id: id}, size), do: card_url(id, size)

  def card_url(id, size),
    do: "https://art.hearthstonejson.com/v1/render/latest/enUS/#{size}/#{id}.png"

  def update_table(_cards, :undefined), do: nil

  def update_table(cards, table) do
    cards
    |> Enum.each(fn c ->
      :ets.insert(table, {"card_#{c.dbf_id}", c})
      :ets.insert(table, {"card_class_#{c.dbf_id}", c.card_class})
    end)

    :ets.insert(table, {"all_cards", cards})
    :ets.insert(table, {"collectible_cards", cards |> Enum.filter(& &1.collectible)})
  end

  def get_class(dbf_id) do
    table()
    |> Util.ets_lookup("card_class_#{dbf_id}")
  end

  def table(), do: :ets.whereis(@name)

  """
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
  def collectible_cards(), do: table() |> Util.ets_lookup("collection_cards", [])

  def handle_cast({:update_cards}, state = %{table: table}) do
    get_fresh() |> update_table(table)
    {:noreply, state}
  end

  def up?(), do: GenServer.whereis(@name) != nil
end
