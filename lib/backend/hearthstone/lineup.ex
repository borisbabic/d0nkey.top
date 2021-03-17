defmodule Backend.Hearthstone.Lineup do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Hearthstone.Deck

  schema "lineups" do
    field :name, :string
    field :tournament_id, :string
    field :tournament_source, :string
    many_to_many :decks, Deck, join_through: "lineup_decks", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(lineup, attrs, decks) do
    lineup
    |> cast(attrs, [:tournament_id, :tournament_source, :name])
    |> put_assoc(:decks, decks)
    |> validate_required([:tournament_id, :tournament_source, :name])
  end
end
