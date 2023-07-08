defmodule Hearthstone.DeckTracker.CardGameTally do
  @moduledoc "Tally of a instance of a card's usage in a game"
  use Ecto.Schema
  import Ecto.Changeset
  alias Hearthstone.DeckTracker.Game
  alias Backend.Hearthstone.Card

  schema "dt_card_game_tally" do
    belongs_to :game, Game
    belongs_to :card, Card
    field :drawn, :boolean, default: true
    field :mulligan, :boolean, default: false
    field :turn, :integer, default: 0
    field :kept, :boolean, default: false
  end

  def changeset(tally, attrs) do
    tally
    |> cast(attrs, [:game_id, :card_id, :drawn, :mulligan, :turn, :kept])
  end
end
