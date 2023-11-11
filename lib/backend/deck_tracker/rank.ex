defmodule Hearthstone.DeckTracker.Rank do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ranks" do
    field :auto_aggregate, :boolean, default: false
    field :display, :string
    field :include_in_deck_filters, :boolean, default: false
    field :include_in_personal_filters, :boolean, default: false
    field :max_legend_rank, :integer, default: nil
    field :max_rank, :integer, default: nil
    field :min_legend_rank, :integer, default: 0
    field :min_rank, :integer, default: 0
    field :order_priority, :integer, default: 0
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(rank, attrs) do
    rank
    |> cast(attrs, [
      :slug,
      :display,
      :min_rank,
      :max_rank,
      :min_legend_rank,
      :max_legend_rank,
      :include_in_personal_filters,
      :include_in_deck_filters,
      :order_priority,
      :auto_aggregate
    ])
    |> validate_required([
      :slug,
      :display,
      :min_rank,
      :include_in_personal_filters,
      :include_in_deck_filters,
      :order_priority,
      :auto_aggregate
    ])
  end
end
