defmodule Backend.Hearthstone.LineupDeck do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Hearthstone.Lineup
  alias Backend.Hearthstone.Deck

  schema "lineup_decks" do
    belongs_to :lineup, Lineup, primary_key: true
    belongs_to :deck, Deck, primary_key: true
  end

  @doc false
  def changeset(lineup_deck, attrs) do
    lineup_deck
    |> cast(attrs, [])
    |> validate_required([])
  end
end
