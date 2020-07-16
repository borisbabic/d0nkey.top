defmodule Backend.HearthstoneJson do
  @moduledoc false

  use GenServer
  @name :hearthstone_json
  alias Backend.Infrastructure.HearthstoneJsonCommunicator, as: Api
  alias Backend.HearthstoneJson.Card

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  @spec get_fresh() :: [Card]
  def get_fresh() do
    Api.get_collectible_cards()
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

  def create_state(cards) do
    class_map = create_class_map(cards)
    %{cards: cards, class_map: class_map}
  end

  def create_class_map(cards) do
    cards
    |> Enum.map(fn c -> {c.dbf_id, c.card_class} end)
    |> Map.new()
  end

  def get_class(dbf_id) do
    GenServer.call(@name, {:get_class, dbf_id})
  end

  def handle_call({:get_class, dbf_id}, _from, s = %{class_map: cm}), do: {:reply, cm[dbf_id], s}

  def handle_cast({:update_cards}, old_state) do
    state = get_fresh() |> create_state()
    {:noreply, state}
  end
end
