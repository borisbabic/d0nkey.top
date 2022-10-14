defmodule Backend.Leaderboards.Entry do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Leaderboards.Season

  schema "leaderboards_entry" do
    field :account_id, :string
    field :rank, :integer
    field :rating, :float, default: nil
    belongs_to :season, Season

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:rank, :account_id, :rating, :season_id, :inserted_at])
    |> validate_required([:rank, :season_id])
  end
end
