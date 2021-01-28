defmodule Backend.Hearthstone do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.Hearthstone.Deck
  require Logger

  def create_or_get_deck(deckcode) when is_binary(deckcode),
    do: deckcode |> Deck.decode!() |> create_or_get_deck()

  def create_or_get_deck(%{cards: cards, hero: hero, format: format}),
    do: create_or_get_deck(cards, hero, format)

  def create_or_get_deck(cards, hero, format) do
    deck(cards, hero, format)
    |> case do
      nil -> create_deck(cards, hero, format)
      deck -> {:ok, deck}
    end
  end

  def deck(%{id: id}) when is_integer(id), do: deck(id)
  def deck(%{cards: cards, hero: hero, format: format}), do: deck(cards, hero, format)
  def deck(id), do: Repo.get(Deck, id)

  def deck(cards, hero, format) do
    class = hero |> Backend.HearthstoneJson.get_class()

    query =
      from d in Deck,
        where:
          fragment("? @> ?", d.cards, ^cards) and
            fragment("? <@ ?", d.cards, ^cards) and
            d.format == ^format and
            d.class == ^class,
        select: d,
        order_by: [desc: :updated_at],
        limit: 1

    Repo.one(query)
  end

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

  @spec recalculate_archetypes(Integer.t() | String.t()) :: {:ok, any()} | {:error, any()}
  def recalculate_archetypes(<<"min_ago_"::binary, min_ago::bitstring>>),
    do: recalculate_archetypes(min_ago)

  def recalculate_archetypes(minutes_ago) when is_binary(minutes_ago) do
    case Integer.parse(minutes_ago) do
      {num, _} -> recalculate_archetypes(num)
      _ -> {:error, "Couldn't parse integer"}
    end
  end

  def recalculate_archetypes(minutes_ago) when is_integer(minutes_ago) do
    decks = decks([{"latest", minutes_ago}])
    Logger.info("Recalculating archetypes for #{decks |> Enum.count()} decks")

    decks
    |> Enum.chunk_every(100)
    |> Enum.each(fn chunk ->
      Logger.info("Recalculating archetypes...")

      chunk
      |> Enum.reduce(Multi.new(), fn d, multi ->
        new_archetype = Backend.HSReplay.guess_archetype(d)
        updated = d |> Deck.changeset(%{hsreplay_archetype: new_archetype, deckcode: d.deckcode})
        Multi.update(multi, to_string(d.id), updated)
      end)
      |> Repo.transaction()
    end)

    {:ok, "Done"}
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

  defp compose_decks_query(
         {"latest", <<"min_ago_"::binary, min_ago::bitstring>>},
         query
       ) do
    min_ago
    |> Integer.parse()
    |> case do
      {num, _} -> compose_decks_query({"last_played", num}, query)
      _ -> query
    end
  end

  defp compose_decks_query({"latest", min_ago}, query) when is_integer(min_ago),
    do: query |> where([d], d.inserted_at >= ago(^min_ago, "minute"))

  defp compose_decks_query(unrecognized, query) do
    Logger.warn("Couldn't compose #{__MODULE__} query: #{inspect(unrecognized)}")
    query
  end

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
