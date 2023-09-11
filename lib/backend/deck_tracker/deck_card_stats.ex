defmodule Hearthstone.DeckTracker.DeckCardStats do
  @moduledoc "Holds aggregated card stats for decks"

  use Ecto.Schema
  import Ecto.Changeset
  alias Hearthstone.DeckTracker.PeriodUpdate
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Card

  schema "dt_deck_card_stats" do
    belongs_to :period_update, PeriodUpdate
    belongs_to :card, Card
    belongs_to :deck, Deck
    field :drawn_count, :integer
    field :drawn_impact, :float
    field :mull_count, :float
    field :mull_impact, :float
  end

  def changeset(cs, attrs) do
    cs
    |> cast(attrs, [
      :period_update_id,
      :card_id,
      :deck_id,
      :drawn_count,
      :mull_count,
      :mull_impact
    ])
  end
end
