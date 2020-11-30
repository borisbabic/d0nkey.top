defmodule BackendWeb.Schema.StreamerDeckTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  alias BackendWeb.Resolvers

  import_types(Absinthe.Type.Custom)

  object :streamer_deck_queries do
    field :streamer_decks, list_of(:streamer_deck) do
      arg(:limit, :integer)
      arg(:offset, :integer)
      arg(:format, :integer)
      arg(:twitch_id, :integer)
      resolve(&Resolvers.StreamerDecks.list_streamer_decks/3)
    end
  end

  node object(:streamer_deck) do
    field :best_rank, :integer
    field :best_legend_rank, :integer
    field :worst_legend_rank, :integer
    field :latest_legend_rank, :integer
    field :first_played, :naive_datetime
    field :last_played, :naive_datetime
    field :minutes_played, :integer
    field :game_type, :integer
    field :streamer, :streamer
    field :deck, :deck
  end

  node object(:streamer) do
    field :twitch_id, :integer

    field :twitch_login, :string do
      arg(:equal, :string)
    end

    field :twitch_display, :string

    field :hsreplay_twitch_login, :string,
      deprecate: "Use the non hsreplay version when available"

    field :hsreplay_twitch_display, :string,
      deprecate: "Use the non hsreplay version when available"
  end

  node object(:deck) do
    field :cards, list_of(:integer), description: "List of dbf ids"
    field :deckcode, :string
    field :format, :integer
    field :hero, :integer, description: "Dbf id"
    field :class, :string
  end
end
