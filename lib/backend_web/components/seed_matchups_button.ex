defmodule Components.SeedMatchupsButton do
  @moduledoc """
  A button that seeds matchups weights.
  """
  use BackendWeb, :surface_live_component
  import Components.MatchupsTable, only: [store_weights: 2]
  prop(button_title, :string, default: "Seed Matchups Weights")
  prop(weights, :map, required: true)

  def render(assigns) do
    ~F"""
    <button class="button" :on-click="seed_matchups_weights" phx-hook="LocalStorage">
      {@button_title}
    </button>
    """
  end

  def handle_event("seed_matchups_weights", _, socket) do
    weights = socket.assigns.weights
    {:noreply, socket |> store_weights(weights)}
  end
end
