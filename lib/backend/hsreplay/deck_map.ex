defmodule Backend.HSReplay.DeckMap do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Hearthstone.Deck
  schema "hsr_deck_map" do
    belongs_to :deck, Deck
    field :hsr_deck_id, :string
  end

  @doc false
  def changeset(c, attrs) do
    c
    |> cast(attrs, [:deck_id, :hsr_deck_id])
    |> validate_required([:deck_id, :hsr_deck_id])
  end
end
