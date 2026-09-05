defmodule Backend.BracketPredictions.Match do
  @moduledoc """
  Represents a single match node in the tournament DAG.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.BracketPredictions.Tournament
  alias Backend.BracketPredictions.Stage
  alias Backend.BracketPredictions.Pick

  schema "bracket_matches" do
    field :group_name, :string
    field :round_number, :integer, default: 1
    field :round_name, :string
    field :match_identifier, :string
    field :match_order, :integer, default: 0

    field :top_source_type, :string, default: "seed"
    field :top_source_identifier, :string
    field :bottom_source_type, :string, default: "seed"
    field :bottom_source_identifier, :string

    field :top_name, :string
    field :bottom_name, :string
    field :top_score, :integer
    field :bottom_score, :integer
    field :actual_winner_name, :string
    field :is_complete, :boolean, default: false
    field :battlefy_match_id, :string

    belongs_to :tournament, Tournament
    belongs_to :stage, Stage
    has_many :picks, Pick, foreign_key: :match_id

    timestamps()
  end

  @valid_source_types ["seed", "winner_of", "loser_of", "stage_advancement"]

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [
      :tournament_id,
      :stage_id,
      :group_name,
      :round_number,
      :round_name,
      :match_identifier,
      :match_order,
      :top_source_type,
      :top_source_identifier,
      :bottom_source_type,
      :bottom_source_identifier,
      :top_name,
      :bottom_name,
      :top_score,
      :bottom_score,
      :actual_winner_name,
      :is_complete,
      :battlefy_match_id
    ])
    |> validate_required([:tournament_id, :stage_id, :round_name, :match_identifier])
    |> validate_inclusion(:top_source_type, @valid_source_types)
    |> validate_inclusion(:bottom_source_type, @valid_source_types)
    |> foreign_key_constraint(:tournament_id)
    |> foreign_key_constraint(:stage_id)
    |> unique_constraint([:tournament_id, :match_identifier])
  end
end
