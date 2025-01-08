defmodule BackendWeb.CardsJSON do
  def ids(%{cards: cards}), do: %{ids: Enum.map(cards, & &1.id)}
  def cards(%{cards: cards}), do: %{cards: cards}
  def metadata(%{metadata: metadata}), do: %{metadata: metadata}
end
