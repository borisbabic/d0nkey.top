defmodule Hearthstone.DeckTracker.Period do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dt_periods" do
    field :auto_aggregate, :boolean, default: false
    field :display, :string
    field :hours_ago, :integer
    field :include_in_deck_filters, :boolean, default: false
    field :include_in_personal_filters, :boolean, default: false
    field :period_end, :naive_datetime
    field :period_start, :naive_datetime
    field :slug, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(period, attrs) do
    period
    |> cast(attrs, [
      :slug,
      :display,
      :type,
      :period_start,
      :period_end,
      :hours_ago,
      :include_in_personal_filters,
      :include_in_deck_filters,
      :auto_aggregate
    ])
    |> validate_required([
      :slug,
      :display,
      :type,
      :period_start,
      :period_end,
      :hours_ago,
      :include_in_personal_filters,
      :include_in_deck_filters,
      :auto_aggregate
    ])
  end
end
