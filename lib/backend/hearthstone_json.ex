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

  def get_card(dbf_id), do: Util.gs_call_if_up(@name, {:get_card, dbf_id})

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
    state = if(args[:fetch_fresh], do: get_fresh(), else: get_json()) |> create_state()

    {:ok, state}
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

  def create_state(cards) do
    class_map = create_class_map(cards)
    card_map = cards |> Enum.map(fn c -> {c.dbf_id, c} end) |> Map.new()
    %{cards: cards, class_map: class_map, card_map: card_map}
  end

  def create_class_map(cards) do
    cards
    |> Enum.map(fn c -> {c.dbf_id, c.card_class} end)
    |> Map.new()
  end

  def get_class(dbf_id), do: Util.gs_call_if_up(@name, {:get_class, dbf_id})

  """
  If the hero isn't available then it defaults to the basic hero for the class
  """

  @spec get_hero(Deck.t()) :: Backend.HearthstoneJson.Card.t()
  def get_hero(deck), do: Util.gs_call_if_up(@name, {:get_hero, deck})

  def cards(), do: Util.gs_call_if_up(@name, {:cards}, [])

  def handle_call({:cards}, _from, s = %{cards: cards}), do: {:reply, cards, s}
  def handle_call({:get_class, dbf_id}, _from, s = %{class_map: cm}), do: {:reply, cm[dbf_id], s}
  def handle_call({:get_card, dbf_id}, _from, s = %{card_map: cm}), do: {:reply, cm[dbf_id], s}

  def handle_call({:get_hero, deck}, _from, s = %{card_map: cm}) do
    hero =
      with nil <- cm[deck.hero] do
        cm[Deck.get_basic_hero(deck.class)]
      else
        hero -> hero
      end

    {:reply, hero, s}
  end

  def handle_cast({:update_cards}, _old_state) do
    state = get_fresh() |> create_state()
    {:noreply, state}
  end

  def up?(), do: GenServer.whereis(@name) != nil
end
