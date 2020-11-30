defmodule BackendWeb.Resolvers.StreamerDecks do
  def list_streamer_decks(_parent, raw_args, resolution) do
    args =
      %{limit: 50, order_by: {:desc, :last_played}}
      |> Map.merge(raw_args)
      |> Enum.map(fn {k, v} -> {to_string(k), v} end)

    {:ok, Backend.Streaming.streamer_decks(args)}
  end

  def find_streamer_deck(id), do: Backend.Streaming.streamer_deck(id)
  def find_streamer(id), do: Backend.Streaming.streamer(id)
  def find_deck(id), do: Backend.Hearthstone.deck(id)
end
