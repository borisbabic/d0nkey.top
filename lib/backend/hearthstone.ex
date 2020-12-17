defmodule Backend.Hearthstone do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.Hearthstone.Deck

  def create_or_get_deck(cards, hero, format) do
    deckcode = Deck.deckcode(cards, hero, format)

    query =
      from d in Deck,
        where: d.deckcode == ^deckcode,
        select: d,
        order_by: [desc: :updated_at],
        limit: 1

    Repo.one(query)
    |> case do
      nil -> create_deck(cards, hero, format)
      deck -> {:ok, deck}
    end
  end

  def deck(id), do: Repo.get(Deck, id)

  def create_deck(cards, hero, format) do
    temp_attrs = %{cards: cards, hero: hero, format: format, class: class(hero)}

    hsreplay_archetype =
      Backend.HSReplay.guess_archetype(temp_attrs)
      |> case do
        %{id: id} -> id
        _ -> nil
      end

    attrs = Map.put(temp_attrs, :hsreplay_archetype, hsreplay_archetype)

    %Deck{}
    |> Deck.changeset(attrs)
    |> Repo.insert()
  end

  def class(%{hero: hero}), do: class(hero)
  def class(dbf_id), do: Backend.HearthstoneJson.get_class(dbf_id)

  def add_class_and_regenerate_deckcode() do
    decks([{"class", nil}])
    |> Enum.reduce(Multi.new(), fn d, multi ->
      deckcode = Deck.deckcode(d)
      updated = d |> Deck.changeset(%{deckcode: deckcode, class: class(d)})
      Multi.update(multi, to_string(d.id) <> deckcode, updated)
    end)
    |> Repo.transaction()
  end

  def decks(criteria) do
    base_decks_query()
    |> build_decks_query(criteria)
    |> Repo.all()
  end

  defp base_decks_query(), do: from(d in Deck)

  defp build_decks_query(query, criteria),
    do: Enum.reduce(criteria, query, &compose_decks_query/2)

  defp compose_decks_query({"class", nil}, query), do: query |> where([d], is_nil(d.class))
  defp compose_decks_query({"class", class}, query), do: query |> where([d], d.class == ^class)

  defp compose_decks_query({"deckcode", deckcode}, query),
    do: query |> where([d], d.deckcode == ^deckcode)

  defp compose_decks_query(_unrecognized, query), do: query

  def darkmoon_faire_out?() do
    now = NaiveDateTime.utc_now()
    release = ~N[2020-11-17 18:00:00]
    NaiveDateTime.compare(now, release) == :gt
  end

  def ordered_frequencies(cards = [a | _]) when is_integer(a) do
    cards
    |> Enum.frequencies()
    |> Enum.map(fn {c, freq} ->
      {get_card(c), freq}
    end)
    |> Enum.filter(&(&1 |> elem(0)))
    |> Enum.sort_by(fn {c, _} -> c.name end)
    |> Enum.sort_by(fn {c, _} -> c.cost end)
  end

  def get_card(dbf_id), do: Backend.HearthstoneJson.get_card(dbf_id)
end
