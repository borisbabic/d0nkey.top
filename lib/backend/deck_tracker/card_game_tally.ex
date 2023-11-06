defmodule Hearthstone.DeckTracker.CardGameTally do
  @moduledoc "Tally of a instance of a card's usage in a game"
  use Ecto.Schema
  import Ecto.Changeset
  alias Hearthstone.DeckTracker.Game
  alias Backend.Hearthstone.Card

  schema "dt_card_game_tally" do
    belongs_to :game, Game
    belongs_to :card, Card
    belongs_to :deck, Deck
    field :drawn, :boolean, default: true
    field :mulligan, :boolean, default: false
    field :turn, :integer, default: 0
    field :kept, :boolean, default: false
    timestamps(updated_at: false)
  end

  def changeset(tally, attrs) do
    tally
    |> cast(attrs, [:game_id, :card_id, :drawn, :mulligan, :turn, :kept, :inserted_at, :deck_id])
  end
end
