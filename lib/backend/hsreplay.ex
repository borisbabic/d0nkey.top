defmodule Backend.HSReplay do
  @moduledoc false
  alias Backend.Infrastructure.HSReplayCommunicator, as: Api
  alias Backend.Infrastructure.ApiCache
  alias Backend.HSReplay.Archetype
  alias Backend.HSReplay.Streaming
  alias Backend.HSReplay.Deck
  alias Backend.HSReplay.DeckMap
  alias Backend.HSReplay.DeckMapper
  alias Backend.HSReplay.StreamerDeckInserter
  alias Backend.Streaming.StreamerDeck
  import Ecto.Query, warn: false
  alias Backend.Repo

  @doc """
  Returns the archetypes with the closest jaro distance
  """
  @spec find_archetypes_by_names([String.t()]) :: {[Backend.HSReplay.Archetype], [String.t()]}
  def find_archetypes_by_names(arch_names) do
    archetypes = get_archetypes()

    # todo remove missing since it will always be empty
    {found, missing} =
      arch_names
      |> Enum.map_reduce([], fn a, acc ->
        normalized = a |> String.trim() |> String.downcase()

        arch =
          archetypes
          |> Enum.sort_by(
            fn a -> String.jaro_distance(a.name |> String.downcase(), normalized) end,
            &Kernel.>=/2
          )
          |> Enum.at(0)

        if arch == nil do
          {arch, [a | acc]}
        else
          {arch, acc}
        end
      end)

    {found |> Enum.reject(&is_nil/1), missing}
  end

  def get_archetype_matchups() do
    Api.get_archetype_matchups()
  end

  def get_archetypes() do
    case {get_archetypes(:cache), Application.get_env(:backend, :disable_hsreplay)} do
      {_, true} -> []
      {nil, _} -> get_archetypes(:fresh) |> cache_archetypes()
      {cache, _} -> cache
    end
  end

  def get_archetypes(:cache) do
    ApiCache.get(:hsreplay_archetypes)
  end

  def get_archetypes(:fresh) do
    Api.get_archetypes()
  end

  def cache_archetypes(archetypes) do
    ApiCache.set(:hsreplay_archetypes, archetypes)
    archetypes
  end

  def get_latest() do
    Cache.list()
  end

  def get_latest(filters) do
    get_latest()
    |> filter_latest(filters)
  end

  def filter_latest(latest, filters) do
    filter_func = create_filter(filters)
    latest |> Enum.filter(filter_func)
  end

  defp normalize_ranks(rank, legend_rank) do
    case {rank, legend_rank} do
      {51, l} -> normalize_legend(l)
      {r, _} when not is_nil(r) -> normalize_regular(r)
      _ -> nil
    end
  end

  def normalize_legend(num) do
    -1 * num
  end

  def normalize_regular(num) do
    -1 * (999_999_999 - num)
  end

  def normalize_ranks(replay_feed_entry) do
    p1rank =
      normalize_ranks(replay_feed_entry.player1_rank, replay_feed_entry.player1_legend_rank)

    p2rank =
      normalize_ranks(replay_feed_entry.player2_rank, replay_feed_entry.player2_legend_rank)

    {p1rank, p2rank}
  end

  def normalize_rank_filter_value(value) do
    case Integer.parse(value) do
      {legend_rank, "L"} -> normalize_legend(legend_rank)
      {rank, ""} -> normalize_regular(rank)
      _ -> nil
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def create_filter_func(name, value) do
    rank_filter_val = normalize_rank_filter_value(value)

    case name do
      "max_rank" when not is_nil(rank_filter_val) ->
        fn re ->
          {p1, p2} = normalize_ranks(re)
          p1 && p1 <= rank_filter_val && (p2 && p2 <= rank_filter_val)
        end

      "max_rank_any" when not is_nil(rank_filter_val) ->
        fn re ->
          {p1, p2} = normalize_ranks(re)
          (p1 && p1 <= rank_filter_val) || (p2 && p2 <= rank_filter_val)
        end

      "min_rank" when not is_nil(rank_filter_val) ->
        fn re ->
          {p1, p2} = normalize_ranks(re)
          p1 && p1 >= rank_filter_val && (p2 && p2 >= rank_filter_val)
        end

      "min_rank_any" when not is_nil(rank_filter_val) ->
        fn re ->
          {p1, p2} = normalize_ranks(re)
          (p1 && p1 >= rank_filter_val) || (p2 && p2 >= rank_filter_val)
        end

      _ ->
        nil
    end
  end

  def create_filter(filter_values) do
    filter_funcs =
      filter_values
      |> Enum.flat_map(fn {key, value} ->
        case create_filter_func(to_string(key), value) do
          nil -> []
          func -> [func]
        end
      end)

    fn a -> filter_funcs |> Enum.reduce(true, fn ff, acc -> ff.(a) && acc end) end
  end

  @spec create_replay_link(String.t()) :: String.t()
  def create_replay_link(match_id) do
    "https://hsreplay.net/replay/#{match_id}"
  end

  @spec create_archetype_link(Archetype.t() | %{url: String.t()} | String.t()) :: String.t()
  def create_archetype_link(%{url: url}) do
    create_archetype_link(url)
  end

  def create_archetype_link(<<url::binary>>) do
    "https://hsreplay.net#{url}"
  end

  def create_deck_link(<<deckcode::binary>>),
    do: "https://hsreplay.net/decks/#{deckcode |> URI.encode_www_form()}"

  @spec get_streaming_now() :: [Streaming.t()]
  def get_streaming_now(), do: Api.get_streaming_now()

  def guess_non_highlander(d = %{class: class_name, format: format}) do
    get_archetypes()
    |> Enum.filter(fn a -> a.player_class_name == class_name end)
    |> Enum.filter(fn a ->
      core = a |> Archetype.signature_core(format)
      limit = NaiveDateTime.utc_now() |> NaiveDateTime.add(-60 * 60 * 24 * 30)
      core && NaiveDateTime.compare(core.as_of, limit) == :gt && !Archetype.highlander?(a)
    end)
    |> match_archetypes(d)
  end

  @spec get_highlander(%{:cards => any, :format => any, optional(any) => any}) :: any
  def get_highlander(d = %{class: class_name}) when not is_nil(class_name) do
    get_highlander(class_name, d)
  end

  def get_highlander(d = %{hero: hero}) do
    hero
    |> Backend.HearthstoneJson.get_class()
    |> get_highlander(d)
  end

  def get_highlander(class_name, d = %{format: format}) do
    get_archetypes()
    |> Enum.filter(fn a ->
      Archetype.signature_core(a, format) &&
        a.player_class_name == class_name &&
        a |> Archetype.highlander?()
    end)
    |> match_archetypes(d)
  end

  def guess_archetype(d = %{cards: cards}) do
    cards
    |> Enum.frequencies()
    |> Enum.max_by(fn {_archetype, freq} -> freq end)
    |> case do
      {_, 1} -> get_highlander(d)
      {_, _} -> guess_non_highlander(d)
    end
  end

  def guess_archetype(%{class: _class_name}), do: nil

  def match_archetypes(archetypes, %{cards: cards, format: format}) do
    archetypes
    |> Enum.map(fn a ->
      core = a |> Archetype.signature_core(format)
      num_matches = (cards -- cards -- core.components) |> Enum.count()
      {num_matches, a}
    end)
    |> Enum.max_by(fn {matches, _} -> matches end, &>=/2, fn -> nil end)
    |> case do
      {matches, a} when matches > 5 -> a
      _ -> nil
    end
  end

  def get_archetype(id) do
    get_archetypes() |> Enum.find(fn a -> a.id == id end)
  end

  def get_latest_archetypes(days \\ 30) do
    reference_time =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-1 * days * 24 * 60 * 60)

    get_archetypes()
    |> Enum.filter(fn a ->
      core = a |> Archetype.signature_core(2)
      core && core.as_of && NaiveDateTime.compare(reference_time, core.as_of) == :lt
    end)
    |> Enum.sort_by(fn a -> a.name end, :asc)
    |> Enum.sort_by(fn a -> a.player_class_name end, :asc)
  end

  def insert_map(hsr_deck_id, %{id: id}) when is_integer(id) do
    attrs = %{hsr_deck_id: hsr_deck_id, deck_id: id}

    %DeckMap{}
    |> DeckMap.changeset(attrs)
    |> Repo.insert()
  end

  def insert_map(hsr_deck_id, deckcode_or_deck) do
    with {:ok, deck = %{id: _id}} <- Backend.Hearthstone.create_or_get_deck(deckcode_or_deck) do
      insert_map(hsr_deck_id, deck)
    end
  end

  def handle_live_decks() do
    ["standard", "wild", "classic", "twist"]
    |> Enum.each(&handle_live_decks/1)
  end

  def handle_live_decks(mode) do
    with {:ok, decks} <- Api.get_live_decks(mode),
         mapped_decks <- mapped_decks(decks),
         existing_streamer_decks <- existing_streamer_decks(decks) do
      DeckMapper.enqueue_jobs(decks -- mapped_decks)
      StreamerDeckInserter.enqueue_jobs(mode, mapped_decks -- existing_streamer_decks)
    end
  end

  defp mapped_decks(hsr_deck_ids) do
    query =
      from dm in DeckMap,
        where: dm.hsr_deck_id in ^hsr_deck_ids,
        select: dm.hsr_deck_id

    Repo.all(query)
  end

  defp existing_streamer_decks(hsr_deck_ids) do
    query =
      from dm in DeckMap,
        inner_join: sd in StreamerDeck,
        on: sd.deck_id == dm.deck_id,
        where: dm.hsr_deck_id in ^hsr_deck_ids,
        select: dm.hsr_deck_id

    Repo.all(query)
  end

  def get_deck(hsr_deck_id) do
    query =
      from dm in DeckMap,
        join: d in assoc(dm, :deck),
        where: dm.hsr_deck_id == ^hsr_deck_id,
        select: d

    case Repo.all(query) do
      [deck] -> {:ok, deck}
      _ -> :error
    end
  end
end
