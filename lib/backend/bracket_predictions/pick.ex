defmodule Backend.BracketPredictions.Pick do
  @moduledoc """
  Represents a single match prediction pick within an entry.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.BracketPredictions.Entry
  alias Backend.BracketPredictions.Match

  schema "bracket_picks" do
    field :picked_winner_name, :string
    field :predicted_top_name, :string
    field :predicted_bottom_name, :string
    field :predicted_top_score, :integer
    field :predicted_bottom_score, :integer
    field :is_correct, :boolean
    field :exact_score_correct, :boolean
    field :points_awarded, :integer, default: 0

    belongs_to :entry, Entry
    belongs_to :match, Match

    timestamps()
  end

  @doc false
  def changeset(pick, attrs) do
    pick
    |> cast(attrs, [
      :entry_id,
      :match_id,
      :picked_winner_name,
      :predicted_top_name,
      :predicted_bottom_name,
      :predicted_top_score,
      :predicted_bottom_score,
      :is_correct,
      :exact_score_correct,
      :points_awarded
    ])
    |> validate_required([:entry_id, :match_id, :picked_winner_name])
    |> foreign_key_constraint(:entry_id)
    |> foreign_key_constraint(:match_id)
    |> unique_constraint([:entry_id, :match_id])
  end
end
