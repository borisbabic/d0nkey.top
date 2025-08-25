defmodule Hearthstone.DeckTracker.GamePlayedCards do
  @moduledoc "Opponent played cards"
  use Ecto.Schema
  import Ecto.Changeset
  alias Hearthstone.DeckTracker.Game

  schema "dt_game_played_cards" do
    belongs_to :game, Game
    field :player_cards, {:array, :integer}
    field :opponent_cards, {:array, :integer}
    field :player_archetype, Ecto.Atom, default: nil
    field :opponent_archetype, Ecto.Atom, default: nil
    field :archetyping_updated_at, :utc_datetime, default: nil
    timestamps(updated_at: false)
  end

  def changeset(played_cards, attrs) do
    played_cards
    |> cast(attrs, [
      :player_cards,
      :opponent_cards,
      :player_archetype,
      :opponent_archetype,
      :archetyping_updated_at
    ])
  end
end
