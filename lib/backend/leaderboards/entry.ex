defmodule Backend.Leaderboards.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Leaderboards.Season

  schema "leaderboards_entry" do
    field :account_id, :string
    field :rank, :integer
    field :rating, :integer
    belongs_to :season, Season

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:rank, :account_id, :rating, :season_id])
    |> validate_required([:rank, :season_id])
  end
end
