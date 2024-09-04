defmodule Backend.Sheets.DeckSheetListing do
  @moduledoc "Entry in a deck sheet/list"

  alias Ecto.Changeset
  alias Backend.Sheets.DeckSheet
  alias Backend.Hearthstone.Deck
  use Ecto.Schema
  import Ecto.Changeset
  @type t() :: %__MODULE__{}
  schema "deck_sheet_listings" do
    belongs_to :deck, Deck
    belongs_to :sheet, DeckSheet
    field :name, :string, default: nil
    field :comment, :string, default: nil
    field :source, :string, default: nil
    field :extra_columns, :map, default: %{}
    timestamps()
  end

  @spec create(DeckSheet.t(), Deck.t(), Map.t()) :: Changeset.t()
  def create(sheet, deck, attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :comment, :source, :extra_columns])
    |> put_assoc(:deck, deck)
    |> put_assoc(:sheet, sheet)
    |> validate_required([])
  end

  @doc false
  @spec changeset(t(), Map.t()) :: Changeset.t()
  def changeset(listing, attrs) do
    listing
    |> cast(attrs, [:name, :extra_columns, :comment, :source])
    |> validate_required([])
  end
end
