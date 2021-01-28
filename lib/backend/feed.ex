defmodule Backend.Feed do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Backend.Feed.DeckInteraction
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck
  alias Backend.Repo

  def inc_deck_copied(deck), do: inc(deck, :copied)
  def inc_deck_expanded(deck), do: inc(deck, :expanded)

  def inc(deck, field) when is_binary(deck) do
    deck
    |> Hearthstone.create_or_get_deck()
    |> Util.ok!()
    |> inc(field)
  end

  def inc(deck = %Deck{}, field) do
    di =
      deck
      |> get_or_create_deck_interaction()
      |> Util.ok!()

    query =
      from di in DeckInteraction,
        where: di.id == ^di.id

    query |> Repo.update_all(inc: [{field, 1}])
  end

  @spec get_or_create_deck_interaction(Deck.t()) :: {:ok, DeckInteraction.t()}
  def get_or_create_deck_interaction(deck = %Deck{}) do
    deck
    |> deck_interaction()
    |> case do
      nil -> create_deck_interaction(deck)
      di -> {:ok, di}
    end
  end

  def create_deck_interaction(deck), do: create_deck_interaction(deck, get_current_start())

  def create_deck_interaction(deck, start) do
    %DeckInteraction{}
    |> DeckInteraction.changeset(%{copied: 0, expanded: 0, period_start: start, deck: deck})
    |> Repo.insert()
  end

  def deck_interaction(deck), do: deck_interaction(deck, get_current_start())

  def deck_interaction(%Deck{id: deck_id}, start) do
    query =
      from di in DeckInteraction,
        join: d in assoc(di, :deck),
        where: d.id == ^deck_id and di.period_start == ^start,
        select: di

    Repo.one(query)
  end

  def get_current_start() do
    now = NaiveDateTime.utc_now()

    NaiveDateTime.new(now.year, now.month, now.day, now.hour, 0, 0)
    |> Util.bangify()
  end
end
