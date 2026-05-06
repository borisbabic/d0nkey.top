defmodule Backend.Hearthstone.JsonCardShimmier do
  @moduledoc false
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def init(_args) do
    BackendWeb.Endpoint.subscribe("hearthstone_json")
    {:ok, nil}
  end

  def handle_info(
        %{topic: "hearthstone_json", payload: %{cards: json_cards, version: version}},
        state
      ) do
    Backend.Hearthstone.add_missing_collectible_from_json(json_cards)
    {:noreply, state}
  end
end
