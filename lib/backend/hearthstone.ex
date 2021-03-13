defmodule Backend.Hearthstone do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Lineup
  require Logger

  @spec create_or_get_deck(String.t() | Deck.t()) :: {:ok, Deck.t()} | {:error, any()}
  def create_or_get_deck(deckcode) when is_binary(deckcode),
    do: deckcode |> Deck.decode!() |> create_or_get_deck()

  def create_or_get_deck(%Deck{cards: cards, hero: hero, format: format}),
    do: create_or_get_deck(cards, hero, format)

  @spec create_or_get_deck([integer()], integer(), integer()) :: {:ok, Deck.t()} | {:error, any()}
  def create_or_get_deck(cards, hero, format) do
    deck(cards, hero, format)
    |> case do
      nil -> create_deck(cards, hero, format)
      deck -> {:ok, deck}
    end
  end

  def deck(%{id: id}) when is_integer(id), do: deck(id)
  def deck(%{cards: cards, hero: hero, format: format}), do: deck(cards, hero, format)
  def deck(id) when is_integer(id), do: Repo.get(Deck, id)

  def deck(id_or_deckcode) when is_binary(id_or_deckcode) do
    id_or_deckcode
    |> Integer.parse()
    |> case do
      {id, _} ->
        deck(id)

      _ ->
        query =
          from d in Deck,
            where: d.deckcode == ^id_or_deckcode,
            limit: 1

        Repo.one(query)
    end
  end

  def deck(cards, hero, format), do: Deck.deckcode(cards, hero, format) |> deck()

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
    |> sort_cards()
  end

  def sort_cards(cards) do
    cards
    |> Enum.sort_by(&name_for_sort/1)
    |> Enum.sort_by(&cost_for_sort/1)
  end

  defp name_for_sort({%{name: name}, _}), do: name
  defp name_for_sort({_, %{name: name}}), do: name
  defp name_for_sort(%{name: name}), do: name
  defp name_for_sort(_), do: nil

  defp cost_for_sort({%{cost: cost}, _}), do: cost
  defp cost_for_sort({_, %{cost: cost}}), do: cost
  defp cost_for_sort(%{cost: cost}), do: cost
  defp cost_for_sort(_), do: nil

  def get_card(dbf_id), do: Backend.HearthstoneJson.get_card(dbf_id)

  @spec get_or_create_lineup(String.t() | integer(), String.t(), String.t(), [String.t()]) ::
          {:ok, Lineup.t()} | {:error, any()}
  def get_or_create_lineup(id, s, n, d) when is_integer(id),
    do: get_or_create_lineup(to_string(id), s, n, d)

  def get_or_create_lineup(tournament_id, tournament_source, name, deckstrings) do
    attrs = %{tournament_id: tournament_id, tournament_source: tournament_source, name: name}

    case lineup(attrs) do
      ln = %{id: _} ->
        {:ok, ln}

      nil ->
        decks =
          deckstrings
          |> Enum.filter(&Deck.valid?/1)
          |> Enum.map(&(&1 |> create_or_get_deck() |> Util.nilify()))
          |> Enum.filter(& &1)

        create_lineup(attrs, decks)
    end
  end

  def lineup(%{tournament_id: tournament_id, tournament_source: tournament_source, name: name}) do
    query =
      from l in Lineup,
        where:
          l.tournament_id == ^tournament_id and l.tournament_source == ^tournament_source and
            l.name == ^name,
        preload: [:decks],
        select: l

    Repo.one(query)
  end

  def lineup(id) do
    query =
      from l in Lineup,
        select: l,
        preload: [:decks],
        where: l.id == ^id

    Repo.one(query)
  end

  def create_lineup(attrs, decks) do
    %Lineup{}
    |> Lineup.changeset(attrs, decks)
    |> Repo.insert()
  end

  def get_lineups(tournament_id, tournament_source) do
    query =
      from l in Lineup,
        where: l.tournament_id == ^tournament_id and l.tournament_source == ^tournament_source,
        preload: [:decks],
        select: l

    query
    |> Repo.all()
  end
end
