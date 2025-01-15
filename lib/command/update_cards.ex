defmodule Command.UpdateCards do
  @moduledoc false
  def update_faction_cards() do
    for %{slug: slug} <- Backend.Hearthstone.factions() do
      Backend.Hearthstone.update_collectible_cards(%{faction: slug})
    end
  end
end
