defmodule Hearthstone.DeckTracker.Format do
  use Ecto.Schema
  import Ecto.Changeset

  schema "formats" do
    field :auto_aggregate, :boolean, default: false
    field :default, :boolean, default: false
    field :display, :string
    field :include_in_deck_filters, :boolean, default: false
    field :include_in_personal_filters, :boolean, default: false
    field :order_priority, :integer, default: 0
    field :value, :integer

    timestamps()
  end

  @doc false
  def changeset(format, attrs) do
    format
    |> cast(attrs, [
      :value,
      :display,
      :order_priority,
      :default,
      :include_in_personal_filters,
      :include_in_deck_filters,
      :auto_aggregate
    ])
    |> validate_required([:display])
  end

  def to_option(%{value: v, display: d}), do: {v, d}
end
