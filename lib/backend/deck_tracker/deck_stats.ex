defmodule Hearthstone.DeckTracker.DeckStats do
  @moduledoc """
  Holds aggregated deck stats
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Hearthstone.Deck

  schema "dt_deck_stats" do
    belongs_to :deck, Deck
    field :opponent_class, :string
    field :wins, :integer
    field :losses, :integer
    field :total, :integer
    field :winrate, :float
    field :rank, :string
    field :hour_start, :utc_datetime
    timestamps(updated_at: false)
  end

  def changeset(ds, raw_attrs) do
    attrs = all_for_nil_class(raw_attrs)

    ds
    |> cast(attrs, [
      :deck_id,
      :hour_start,
      :wins,
      :opponent_class,
      :losses,
      :rank,
      :total,
      :winrate
    ])
    |> unique_constraint([:hour_start, :deck_id, :opponent_class])
  end

  defp all_for_nil_class(raw = %{"opponent_class" => nil}),
    do: Map.put(raw, "opponent_class", "ALL")

  defp all_for_nil_class(raw = %{opponent_class: nil}), do: Map.put(raw, :opponent_class, "ALL")
  defp all_for_nil_class(raw), do: raw
end
