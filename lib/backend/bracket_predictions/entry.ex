defmodule Backend.BracketPredictions.Entry do
  @moduledoc """
  Represents a user's prediction entry for a tournament.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.UserManager.User
  alias Backend.BracketPredictions.Tournament
  alias Backend.BracketPredictions.Pick

  schema "bracket_entries" do
    field :name, :string
    field :total_score, :integer, default: 0
    field :rank, :integer
    field :submitted_at, :naive_datetime

    belongs_to :tournament, Tournament
    belongs_to :user, User
    has_many :picks, Pick, foreign_key: :entry_id

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [
      :name,
      :total_score,
      :rank,
      :submitted_at,
      :tournament_id,
      :user_id
    ])
    |> validate_required([:name, :tournament_id])
    |> foreign_key_constraint(:tournament_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:tournament_id, :user_id], name: :bracket_entries_tournament_user_index)
  end
end
