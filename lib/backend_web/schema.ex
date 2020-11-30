defmodule BackendWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern
  alias BackendWeb.Resolvers

  import_types(__MODULE__.StreamerDeckTypes)

  node interface do
    resolve_type(fn
      %Backend.Streaming.StreamerDeck{}, _ -> :streamer_deck
      %Backend.Streaming.Streamer{}, _ -> :streamer
      %Backend.Hearthstone.Deck{}, _ -> :deck
      _, _ -> nil
    end)
  end

  query do
    import_fields(:streamer_deck_queries)

    node field do
      resolve(fn
        %{type: :streamer_deck, id: id} ->
          Resolvers.StreamerDecks.find_streamer_deck(id)

        %{type: :streamer, id: id} ->
          Resolvers.StreamerDecks.find_streamer(id)

        %{type: :deck, id: id} ->
          Resolvers.StreamerDecks.find_deck(id)

        _ ->
          {:error, "Unknown node"}
      end)
    end
  end
end
