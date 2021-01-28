defmodule Backend.Feed.DeckInteraction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Hearthstone.Deck

  schema "deck_interactions" do
    field :copied, :integer
    field :expanded, :integer
    field :period_start, :utc_datetime, primary_key: true
    belongs_to :deck, Deck, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(deck_interaction, attrs) do
    deck_interaction
    |> cast(attrs, [:copied, :expanded, :period_start])
    |> set_deck(attrs)
    |> validate_required([:copied, :expanded, :period_start])
  end

  defp set_deck(c, %{deck: deck}) do
    c
    |> put_assoc(:deck, deck)
    |> foreign_key_constraint(:deck)
  end

  defp set_deck(c, _), do: c
end
