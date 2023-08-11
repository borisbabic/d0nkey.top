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
    # on the current table
    |> unique_constraint([:account_id, :rank, :rating, :season_id],
      name: :leaderboards_current_entries_unique_index
    )
    |> validate_required([:rank, :season_id])
  end

  def current_table(), do: :leaderboards_current_entries
  def current(), do: {current_table(), __MODULE__}
end
