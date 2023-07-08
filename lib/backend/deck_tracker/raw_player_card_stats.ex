defmodule Hearthstone.DeckTracker.RawPlayerCardStats do
  @moduledoc "Contains the raw player cards stats for when we don't have the info to insert it yet"
  use Ecto.Schema
  import Ecto.Changeset
  alias Hearthstone.DeckTracker.Game
  alias Hearthstone.DeckTracker.CardDrawnDto
  alias Hearthstone.DeckTracker.CardMulliganDto

  schema "dt_raw_player_card_stats" do
    belongs_to :game, Game
    field :cards_in_hand_after_mulligan, {:array, :map}
    field :cards_drawn_from_initial_deck, {:array, :map}
  end

  def changeset(raw_stats, attrs) do
    raw_stats
    |> cast(attrs, [:game_id, :cards_drawn_from_initial_deck, :cards_in_hand_after_mulligan])
  end

  @spec dtos(__MODULE__) :: %{drawn: CardDrawnDto.t(), mull: CardMulliganDto.t()}
  def dtos(%{cards_drawn_from_initial_deck: drawn, cards_in_hand_after_mulligan: mull}) do
    %{
      drawn: CardDrawnDto.from_raw_list(drawn),
      mull: CardMulliganDto.from_raw_list(mull)
    }
  end
end
