defmodule Backend.Hearthstone do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Backend.Hearthstone.Deck

  def create_or_get_deck(cards, hero, format) do
    deckcode = Deck.deckcode(cards, hero, format)

    query =
      from d in Deck,
        where: d.deckcode == ^deckcode,
        select: d

    Repo.one(query)
    |> case do
      nil -> create_deck(cards, hero, format)
      deck -> {:ok, deck}
    end
  end

  def create_deck(cards, hero, format) do
    attrs = %{cards: cards, hero: hero, format: format}

    %Deck{}
    |> Deck.changeset(attrs)
    |> Repo.insert()
  end
end
