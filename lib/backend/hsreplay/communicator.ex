defmodule Backend.HSReplay.Communicator do
  @moduledoc false
  alias Backend.HSReplay.ReplayFeedEntry
  alias Backend.HSReplay.Archetype
  alias Backend.Hearthstone.Deck
  @callback get_replay_feed() :: [ReplayFeedEntry.t()]
  @callback get_archetypes() :: [Archetype.t()]
  @callback get_archetype_matchups() :: [Backend.HSReplay.ArchetypeMatchups.t()]
  @callback get_live_decks(atom() | String.t()) :: {:ok, [String.t()]} | {:error, any()}
  @callback get_deck_streams(atom() | String.t(), String.t()) :: {:ok, [Map.t()]} | {:error, any()}
  @callback get_deck(String.t()) :: {:ok, Deck.t()} | {:error, any()}
end
