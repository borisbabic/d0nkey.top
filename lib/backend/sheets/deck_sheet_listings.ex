defmodule Backend.Sheets.DeckSheetListing do
  @moduledoc "Entry in a deck sheet/list"

  alias Ecto.Changeset
  alias Backend.Sheets.DeckSheet
  alias Backend.Hearthstone.Deck
  use Ecto.Schema
  import Ecto.Changeset
  @type t() :: %__MODULE__{}
  @comment_max_length 4096
  schema "deck_sheet_listings" do
    belongs_to :deck, Deck
    belongs_to :sheet, DeckSheet
    field :name, :string, default: nil
    field :comment, :string, default: nil
    field :source, :string, default: nil
    field :extra_columns, :map, default: %{}
    timestamps()
  end

  @spec create(DeckSheet.t(), Deck.t(), map()) :: Changeset.t()
  def create(sheet, deck, attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :comment, :source, :extra_columns])
    |> put_assoc(:deck, deck)
    |> put_assoc(:sheet, sheet)
    |> validate_required([])
    |> validate_comment_length()
  end

  @doc false
  @spec changeset(t(), map()) :: Changeset.t()
  def changeset(listing, attrs) do
    listing
    |> cast(attrs, [:name, :extra_columns, :comment, :source])
    |> validate_required([])
    |> validate_comment_length()
  end

  defp validate_comment_length(changeset) do
    validate_length(changeset, :comment, max: @comment_max_length)
  end

  @spec comment_max_length() :: integer()
  def comment_max_length, do: @comment_max_length
end
