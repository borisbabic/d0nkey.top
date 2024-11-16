defmodule Hearthstone.DeckTracker.Period do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dt_periods" do
    field(:auto_aggregate, :boolean, default: false)
    field(:display, :string)
    field(:hours_ago, :integer)
    field(:include_in_deck_filters, :boolean, default: false)
    field(:include_in_personal_filters, :boolean, default: false)
    field(:period_end, :naive_datetime)
    field(:period_start, :naive_datetime)
    field(:order_priority, :integer)
    field(:slug, :string)
    field(:type, :string)
    field(:formats, {:array, :integer}, default: Hearthstone.Enums.Format.all_values())

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
      :order_priority,
      :include_in_personal_filters,
      :include_in_deck_filters,
      :formats,
      :auto_aggregate
    ])
    |> validate_required([
      :slug,
      :display,
      :type,
      :include_in_personal_filters,
      :formats,
      :include_in_deck_filters,
      :auto_aggregate
    ])
  end

  def to_option(%{slug: slug, display: display}), do: {slug, display}

  def use_period_start?(%{type: t, period_start: %NaiveDateTime{}})
      when t in ["patch", "release", "all"],
      do: true

  def use_period_start?(_), do: false

  def use_hours_ago?(%{type: t, hours_ago: ha}) when t in ["rolling"] and is_integer(ha), do: true
  def use_hours_ago?(_), do: false
end
