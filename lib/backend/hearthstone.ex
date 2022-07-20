defmodule Backend.Hearthstone do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.DeckArchetyper
  alias Backend.Hearthstone.Lineup
  alias Backend.Hearthstone.LineupDeck
  alias Backend.Hearthstone.CardBackCategory
  alias Backend.Hearthstone.Class
  alias Backend.Hearthstone.GameMode
  alias Backend.Hearthstone.Keyword
  alias Backend.Hearthstone.MercenaryRole
  alias Backend.Hearthstone.MinionType
  alias Backend.Hearthstone.Rarity
  alias Backend.Hearthstone.SetGroup
  alias Backend.Hearthstone.Set
  alias Backend.Hearthstone.SpellSchool
  alias Backend.Hearthstone.Type
  alias Backend.Hearthstone.Card
  alias Backend.HearthstoneJson
  alias Hearthstone.Api
  alias Hearthstone.Card, as: ApiCard
  require Logger

  @type insertable_card :: ApiCard

  def update_metadata() do
    with {:ok,
          %{
            card_back_categories: card_back_categories,
            classes: classes,
            game_modes: game_modes,
            keywords: keywords,
            mercenary_roles: mercenary_roles,
            minion_types: minion_types,
            rarities: rarities,
            set_groups: set_groups,
            sets: sets,
            spell_schools: spell_schools,
            types: types
          }} <- Api.get_metadata() do
      [
        {CardBackCategory, card_back_categories},
        {Class, classes},
        {GameMode, game_modes},
        {Keyword, keywords},
        {MercenaryRole, mercenary_roles},
        {MinionType, minion_types},
        {Rarity, rarities},
        {SetGroup, set_groups},
        {Set, sets},
        {SpellSchool, spell_schools},
        {Type, types}
      ]
      |> Enum.reduce(Multi.new(), &metadata_multi_insert/2)
      |> Repo.transaction()
    end
  end

  @spec metadata_multi_insert({atom(), Map.t()}, Multi.t()) :: Multi.t()
  defp metadata_multi_insert({struct_module, values}, multi) do
    values
    |> Enum.reduce(multi, fn val, m ->
      base_struct = struct(struct_module)
      cs = apply(struct_module, :changeset, [base_struct, val])

      {uniq_val, conflict_target} =
        case Map.get(val, :id) do
          nil -> {Map.get(val, :slug), :slug}
          val -> {val, :id}
        end

      Multi.insert(m, "#{struct_module}__insert__#{uniq_val}", cs,
        on_conflict: {:replace_all_except, [:inserted_at]},
        conflict_target: conflict_target
      )
    end)
  end

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

  def all_cards() do
    query =
      from c in Card,
        preload: [
          :card_set,
          :card_type,
          :copy_of_card,
          :keywords,
          :classes,
          :minion_type,
          :rarity,
          :spell_school
        ]

    Repo.all(query)
  end

  @spec upsert_cards([insertable_card()]) :: {:ok, [Card.t()]} | {:error, any()}
  def upsert_cards(cards) do
    cards_map = Map.new(cards, fn c -> {c.id, c} end)
    # using ecto on_conflict upsert support causes issues with the many_to_many relationships
    # they want to get inserted again
    # so we fetch first instead
    ids = Enum.map(cards, & &1.id)
    existing_query = from c in Card, preload: [:classes, :keywords], where: c.id in ^ids
    existing = Repo.all(existing_query)
    existing_ids = Enum.map(existing, & &1.id)
    new = Enum.reject(cards, &(&1.id in existing_ids))
    multi = Enum.reduce(new, Multi.new(), &card_multi_insert/2)

    Enum.reduce(existing, multi, fn old, m ->
      new_card = Map.get(cards_map, old.id)
      changeset = card_changeset(new_card, old)
      Multi.update(m, "update_card_#{old.id}", changeset)
    end)
    |> Repo.transaction()
  end

  @spec card_multi_insert(insertable_card(), Multi.t()) :: Multi.t()
  defp card_multi_insert(card, multi) do
    changeset = card_changeset(card)

    Multi.insert(
      multi,
      "card_insert_#{card.id}",
      changeset,
      on_conflict: {:replace_all_except, [:id, :keywords, :classes]},
      conflict_target: :id
    )
  end

  @spec card_changeset(insertable_card(), Card.t()) :: Ecto.Changeset.t()
  def card_changeset(upstream_card, card \\ %Card{}) do
    card
    |> Card.changeset(upstream_card)
    |> add_card_assocs(upstream_card)
  end

  @spec add_card_assocs(Ecto.Changeset.t(), insertable_card()) :: Ecto.Changeset.t()
  defp add_card_assocs(changeset, %ApiCard{} = api_card) do
    keyword_ids = api_card.keyword_ids
    class_ids = ApiCard.class_ids(api_card)
    keyword_query = from k in Keyword, where: k.id in ^keyword_ids
    class_query = from c in Class, where: c.id in ^class_ids
    keywords = Repo.all(keyword_query)
    classes = Repo.all(class_query)

    changeset
    |> Card.put_keywords(keywords)
    |> Card.put_classes(classes)
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
    class = class(hero)

    temp_attrs = %{
      cards: cards,
      hero: hero,
      format: format,
      class: class,
      archetype: DeckArchetyper.archetype(format, cards, class)
    }

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
  def class(dbf_id), do: HearthstoneJson.get_class(dbf_id)

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

  def recalculate_archetypes(minutes_ago, min_id \\ 0) when is_integer(minutes_ago) do
    cutoff = NaiveDateTime.utc_now() |> NaiveDateTime.add(-1 * 60 * minutes_ago)
    do_recalculate_archetypes(cutoff, min_id)
  end

  defp do_recalculate_archetypes(cutoff, min_id) do
    query =
      from d in Deck,
        distinct: d.id,
        left_join: dtg in Hearthstone.DeckTracker.Game,
        on: dtg.player_deck_id == d.id,
        order_by: [asc: :id],
        limit: 100,
        where: d.id > ^min_id and (d.inserted_at >= ^cutoff or dtg.inserted_at >= ^cutoff)

    case Repo.all(query) do
      [] ->
        {:ok, "done"}

      decks ->
        recalculate_decks_archetypes(decks)
        %{id: new_min} = Enum.max_by(decks, & &1.id)
        do_recalculate_archetypes(cutoff, new_min)
    end
  end

  def recalculate_decks_archetypes(decks) do
    decks
    |> Enum.chunk_every(100)
    |> Enum.each(fn chunk ->
      id_ints = Enum.map(chunk, & &1.id)
      ids = id_ints |> Enum.join(" ")
      {min, max} = Enum.min_max(id_ints)
      Logger.info("Recalculating archetypes from #{min} to #{max}")
      Logger.debug("Recalculating ids: #{ids}")

      chunk
      |> Enum.reduce(Multi.new(), fn d, multi ->
        new_archetype = Backend.Hearthstone.DeckArchetyper.archetype(d)
        updated = d |> Deck.changeset(%{archetype: new_archetype, deckcode: d.deckcode})
        Multi.update(multi, to_string(d.id), updated)
      end)
      |> Repo.transaction()
    end)
  end

  @spec recalculate_hsreplay_archetypes(Integer.t() | String.t()) ::
          {:ok, any()} | {:error, any()}
  def recalculate_hsreplay_archetypes(<<"min_ago_"::binary, min_ago::bitstring>>),
    do: recalculate_hsreplay_archetypes(min_ago)

  def recalculate_hsreplay_archetypes(minutes_ago) when is_binary(minutes_ago) do
    case Integer.parse(minutes_ago) do
      {num, _} -> recalculate_hsreplay_archetypes(num)
      _ -> {:error, "Couldn't parse integer"}
    end
  end

  def recalculate_hsreplay_archetypes(minutes_ago) when is_integer(minutes_ago) do
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

  @spec decks(list()) :: [Deck.t()]
  def decks(criteria) do
    base_decks_query()
    |> build_decks_query(criteria)
    |> Repo.all()
  end

  @spec archetypes(list()) :: [atom()]
  def archetypes(criteria) do
    base_archetypes_query()
    |> build_decks_query(criteria)
    |> Repo.all()
  end

  defp base_decks_query(), do: from(d in Deck, as: :deck)

  defp base_archetypes_query(),
    do:
      from(d in Deck, as: :deck)
      |> select([deck: d], d.archetype)
      |> distinct([deck: d], d.archetype)
      |> where([deck: d], not is_nil(d.archetype))

  defp build_decks_query(query, criteria),
    do: Enum.reduce(criteria, query, &compose_decks_query/2)

  defp compose_decks_query({"class", nil}, query), do: query |> where([deck: d], is_nil(d.class))

  defp compose_decks_query({"class", class}, query),
    do: query |> where([deck: d], d.class == ^class)

  defp compose_decks_query({"deckcode", deckcode}, query),
    do: query |> where([deck: d], d.deckcode == ^deckcode)

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
    do: query |> where([deck: d], d.inserted_at >= ago(^min_ago, "minute"))

  defp compose_decks_query(
         {"recently_played", <<"min_ago_"::binary, min_ago::bitstring>>},
         query
       ) do
    min_ago
    |> Integer.parse()
    |> case do
      {num, _} -> compose_decks_query({"recently_played", num}, query)
      _ -> query
    end
  end

  defp compose_decks_query({"recently_played", min_ago}, query) when is_integer(min_ago),
    do:
      query
      |> join(:inner, [deck: d], dtg in Hearthstone.DeckTracker.Game,
        on: dtg.player_deck_id == d.id,
        as: :game
      )
      |> where([game: g], g.inserted_at >= ago(^min_ago, "minute"))

  defp compose_decks_query({"include_cards", cards = [_ | _]}, query),
    do: query |> where([deck: d], fragment("? @> ?", d.cards, ^cards))

  defp compose_decks_query({"include_cards", []}, query), do: query

  defp compose_decks_query({"exclude_cards", cards = [_ | _]}, query),
    do: query |> where([deck: d], fragment("NOT(? && ?)", d.cards, ^cards))

  defp compose_decks_query({"exclude_cards", []}, query), do: query

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

  def ordered_frequencies(_), do: []

  def sort_cards(cards) do
    cards
    |> Enum.sort_by(&name_for_sort/1)
    |> Enum.sort_by(&cost_for_sort/1)
  end

  defp name_for_sort({%{name: name}, _}), do: name
  defp name_for_sort({_, %{name: name}}), do: name
  defp name_for_sort(%{name: name}), do: name
  defp name_for_sort(_), do: nil

  defp cost_for_sort({%{mana_cost: cost}, _}), do: cost
  defp cost_for_sort({_, %{mana_cost: cost}}), do: cost
  defp cost_for_sort(%{mana_cost: cost}), do: cost
  defp cost_for_sort({%{cost: cost}, _}), do: cost
  defp cost_for_sort({_, %{cost: cost}}), do: cost
  defp cost_for_sort(%{cost: cost}), do: cost
  defp cost_for_sort(_), do: nil

  def get_card(dbf_id), do: HearthstoneJson.get_card(dbf_id)

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
        insert_lineup(attrs, deckstrings)
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

  def create_lineup(attrs, deckstrings) do
    decks =
      deckstrings
      |> Enum.filter(&Deck.valid?/1)
      |> Enum.map(&(&1 |> create_or_get_deck() |> Util.nilify()))
      |> Enum.filter(& &1)

    %Lineup{}
    |> Lineup.changeset(attrs, decks)
  end

  def insert_lineup(attrs, deckstrings) do
    create_lineup(attrs, deckstrings)
    |> Repo.insert()
  end

  def get_lineups(tournament_id, tournament_source) do
    query =
      from l in Lineup,
        where: l.tournament_id == ^tournament_id and l.tournament_source == ^tournament_source,
        select: l

    query
    |> Repo.all()
  end

  def parse_gm_season("2020_2"), do: {:ok, {2020, 2}}
  def parse_gm_season("2021_1"), do: {:ok, {2021, 1}}
  def parse_gm_season("2021_2"), do: {:ok, {2021, 2}}
  def parse_gm_season("2022_1"), do: {:ok, {2022, 1}}
  def parse_gm_season("2022_2"), do: {:ok, {2022, 2}}
  def parse_gm_season(_), do: :error

  def parse_gm_season!(s), do: s |> parse_gm_season() |> Util.bangify()

  def lineups(criteria) do
    base_lineups_query()
    |> build_lineups_query(criteria)
    |> Repo.all()
  end

  defp base_lineups_query() do
    from l in Lineup,
      as: :lineup,
      join: ld in assoc(l, :decks),
      preload: [decks: ld]
  end

  defp build_lineups_query(query, criteria),
    do: Enum.reduce(criteria, query, &compose_lineups_query/2)

  # should return no results
  defp compose_lineups_query({"tournament_id", nil}, query) do
    query
    |> where([lineup: l], 1 == 2)
  end

  defp compose_lineups_query({"tournament_id", tournament_id}, query) do
    query
    |> where([lineup: l], l.tournament_id == ^tournament_id)
  end

  defp compose_lineups_query({"tournament_source", tournament_source}, query) do
    query
    |> where([lineup: l], l.tournament_source == ^tournament_source)
  end

  defp compose_lineups_query({"decks", decks}, query) do
    decks
    |> Enum.reduce(query, &lineup_deck_subquery/2)
  end

  defp compose_lineups_query({"order_by", {direction, field}}, query) do
    query
    |> order_by([{^direction, ^field}])
  end

  defp lineup_deck_subquery(criteria, query) do
    base_query =
      from ld in LineupDeck,
        as: :lineup_deck,
        join: d in assoc(ld, :deck),
        as: :deck,
        select: ld.lineup_id

    sub_query = criteria |> Enum.reduce(base_query, &compose_decks_query/2)
    query |> where([lineup: l], l.id in subquery(sub_query))
  end
end
