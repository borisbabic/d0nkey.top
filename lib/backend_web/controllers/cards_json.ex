defmodule BackendWeb.CardsJSON do
  def ids(%{cards: cards}), do: %{ids: Enum.map(cards, & &1.id)}
  def cards(%{cards: cards}), do: %{cards: cards}
  def last_updated(%{last_updated: last_updated}), do: %{last_updated: Timex.to_unix(last_updated)}
  def metadata(%{metadata: metadata}), do: %{metadata: metadata}
end
