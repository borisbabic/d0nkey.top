defmodule Backend.Streaming do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.HSReplay
  alias Backend.Streaming.Streamer
  alias Backend.Streaming.StreamerDeck
  alias Hearthstone.Enums.BnetGameType

  def relevant_bnet_game_type?(%{game_type: bnet_game_type}) do
    BnetGameType.constructed?(bnet_game_type)
  end

  def ranks(sn = %{game_type: bnet_game_type}) do
    if BnetGameType.ladder?(bnet_game_type) do
      %{rank: sn.rank, legend_rank: sn.legend_rank}
    else
      %{rank: 0, legend_rank: 0}
    end
  end

  def get_latest_streamer_decks(limit \\ 300) do
    query =
      from sd in StreamerDeck,
        join: s in assoc(sd, :streamer),
        join: d in assoc(sd, :deck),
        preload: [streamer: s, deck: d],
        select: sd,
        order_by: [desc: sd.last_played],
        limit: ^limit

    Repo.all(query)
  end

  def get_streamers_decks(hsreplay_twitch_login) do
    query =
      from sd in StreamerDeck,
        join: s in assoc(sd, :streamer),
        join: d in assoc(sd, :deck),
        preload: [streamer: s, deck: d],
        select: sd,
        order_by: [desc: sd.last_played],
        where: s.hsreplay_twitch_login == ^hsreplay_twitch_login

    Repo.all(query)
  end

  def update_streamer_decks() do
    HSReplay.get_streaming_now()
    |> update_streamer_decks()
  end

  def update_streamer_decks(streaming_now) do
    streaming_now
    |> Enum.filter(&relevant_bnet_game_type?/1)
    |> Enum.map(fn sn ->
      with {:ok, deck} <- Backend.Hearthstone.create_or_get_deck(sn.deck, sn.hero, sn.format),
           {:ok, streamer} <-
             get_or_create_streamer(sn.twitch.login, sn.twitch.display_name, sn.twitch.id),
           do: get_or_create_streamer_deck(deck, streamer, sn)
    end)
  end

  def get_or_create_streamer(hsreplay_twitch_login, hsreplay_twitch_display, twitch_id) do
    query =
      from s in Streamer,
        where: s.twitch_id == ^twitch_id,
        select: s

    query
    |> Repo.one()
    |> case do
      nil -> create_streamer(hsreplay_twitch_login, hsreplay_twitch_display, twitch_id)
      s -> {:ok, s}
    end
  end

  def create_streamer(hsreplay_twitch_login, hsreplay_twitch_display, twitch_id) do
    attrs = %{
      hsreplay_twitch_login: hsreplay_twitch_login,
      hsreplay_twitch_display: hsreplay_twitch_display,
      twitch_id: twitch_id
    }

    %Streamer{}
    |> Streamer.changeset(attrs)
    |> Repo.insert()
  end

  def get_or_create_streamer_deck(deck, streamer, sn) do
    query =
      from sd in StreamerDeck,
        join: s in assoc(sd, :streamer),
        join: d in assoc(sd, :deck),
        preload: [streamer: s, deck: d],
        where: s.id == ^streamer.id and d.id == ^deck.id,
        select: sd

    query
    |> Repo.one()
    |> case do
      nil -> create_streamer_deck(deck, streamer, sn)
      sd -> update_streamer_deck(sd, sn)
    end
  end

  def create_streamer_deck(deck, streamer, sn) do
    now = DateTime.utc_now()
    %{rank: rank, legend_rank: legend_rank} = ranks(sn)

    attrs = %{
      deck: deck,
      streamer: streamer,
      best_rank: rank,
      best_legend_rank: legend_rank,
      worst_legend_rank: legend_rank,
      latest_legend_rank: legend_rank,
      game_type: sn.game_type,
      first_played: now,
      last_played: now
    }

    %StreamerDeck{}
    |> StreamerDeck.changeset(attrs)
    |> Repo.insert()
  end

  defp non_zero_min(ranks) do
    ranks
    |> Enum.filter(fn r -> r > 0 end)
    |> case do
      [] -> 0
      r -> Enum.min(r)
    end
  end

  def update_twitch_info(twitch_streams) do
    twitch_streams
    |> Util.async_map(fn ts ->
      login = ts |> Twitch.Stream.login()
      id = ts.user_id

      updates =
        if is_binary(login) do
          [twitch_login: login]
        else
          []
        end
        |> Kernel.++(twitch_display: ts.user_name)

      Repo.update_all(from(s in Streamer, where: s.twitch_id == ^id), set: updates)
    end)
  end

  def update_streamer_deck(ds = %StreamerDeck{}, sn) do
    if should_update?(ds, sn) do
      %{rank: rank, legend_rank: legend_rank} = ranks(sn)

      attrs = %{
        best_rank: [rank, ds.best_rank] |> non_zero_min(),
        best_legend_rank: [legend_rank, ds.best_legend_rank] |> non_zero_min(),
        worst_legend_rank: Enum.max([legend_rank, ds.worst_legend_rank, 0]),
        latest_legend_rank: legend_rank || 0,
        game_type: sn.game_type,
        minutes_played: ds.minutes_played + 1,
        last_played: NaiveDateTime.utc_now()
      }

      ds
      |> StreamerDeck.changeset(attrs)
      |> Repo.update()
    else
      ds
    end
  end

  def should_update?(ds, sn) do
    !recent?(ds) || reasonable_legend_change?(ds, sn)
  end

  def recent?(%{updated_at: ua}) do
    line = NaiveDateTime.utc_now() |> NaiveDateTime.add(-15 * 60)
    NaiveDateTime.compare(ua, line) == :gt
  end

  @doc """
  Check if the legend ranks are withing range for updating
  When a streamer spectates somebody upstream will sends us the streamers deck but the spectatee's rank
  So we want to reject obvious mismatches, >25% diff outside of the top 50
  ## Example
  iex> Backend.Streaming.reasonable_legend_change?(%{latest_legend_rank: 1}, %{legend_rank: 2, rank: 0, game_type: 2}) 
  true
  iex> Backend.Streaming.reasonable_legend_change?(%{latest_legend_rank: 900}, %{legend_rank: 800, rank: 0, game_type: 2})
  true
  iex> Backend.Streaming.reasonable_legend_change?(%{latest_legend_rank: 5000}, %{legend_rank: 40, rank: 0, game_type: 2})
  false
  """
  @spec reasonable_legend_change?(StreamerDeck.t(), StreamingNow.t()) :: boolean
  def reasonable_legend_change?(%{latest_legend_rank: 0}, _), do: true
  def reasonable_legend_change?(_, %{legend_rank: nil}), do: true
  def reasonable_legend_change?(_, %{legend_rank: 0}), do: true

  def reasonable_legend_change?(%{latest_legend_rank: llr}, sn) do
    %{legend_rank: lr} = ranks(sn)

    case {lr, llr} do
      {0, _} -> true
      {lr, llr} when lr < 50 and llr < 50 -> true
      {lr, llr} -> 0.25 >= abs(lr - llr) / llr
    end
  end

  def streamers(criteria) do
    base_streamers_query()
    |> build_streamers_query(criteria)
    |> Repo.all()
  end

  def base_streamers_query() do
    from(s in Streamer)
  end

  defp build_streamers_query(query, criteria),
    do: Enum.reduce(criteria, query, &compose_streamers_query/2)

  defp compose_streamers_query({"order_by", {direction, field}}, query) do
    query
    |> order_by([{^direction, ^field}])
  end

  defp compose_streamers_query(_unrecognized, query), do: query

  def streamer(id), do: Repo.get(Streamer, id)
  def streamer_deck(id), do: Repo.get(StreamerDeck, id)
  def streamer_decks_by_deck(deck_id), do: [{"deck_id", deck_id}] |> streamer_decks()

  def streamer_decks(criteria) do
    base_streamer_decks_query()
    |> build_streamer_deck_query(criteria)
    |> Repo.all()
  end

  defp base_streamer_decks_query() do
    from sd in StreamerDeck,
      join: s in assoc(sd, :streamer),
      join: d in assoc(sd, :deck),
      preload: [streamer: s, deck: d]
  end

  defp build_streamer_deck_query(query, criteria),
    do: Enum.reduce(criteria, query, &compose_streamer_deck_query/2)

  defp compose_streamer_deck_query({"twitch_login", <<twitch_login::binary>>}, query),
    do:
      compose_streamer_deck_query(
        {"twitch_login", String.split(twitch_login, ",")},
        query
      )

  defp compose_streamer_deck_query({"twitch_login", twitch_login}, query) do
    query
    |> join(:inner, [sd], s in assoc(sd, :streamer))
    |> where(
      [_sd, s, _d],
      s.hsreplay_twitch_login in ^twitch_login or s.twitch_login in ^twitch_login
    )
  end

  defp compose_streamer_deck_query({"twitch_id", <<twitch_id::binary>>}, query),
    do: compose_streamer_deck_query({"twitch_id", String.split(twitch_id, ",")}, query)

  defp compose_streamer_deck_query({"twitch_id", twitch_id}, query) when is_list(twitch_id) do
    query
    |> join(:inner, [sd], s in assoc(sd, :streamer))
    |> where([_sd, s, _d], s.twitch_id in ^twitch_id)
  end

  defp compose_streamer_deck_query({"order_by", {direction, field}}, query) do
    query
    |> order_by([{^direction, ^field}])
  end

  defp compose_streamer_deck_query({"limit", limit}, query), do: query |> limit(^limit)
  defp compose_streamer_deck_query({"offset", offset}, query), do: query |> offset(^offset)

  defp compose_streamer_deck_query({"class", class}, query),
    do: query |> where([_sd, _s, d], d.class == ^class)

  defp compose_streamer_deck_query({"include_cards", []}, query), do: query

  defp compose_streamer_deck_query({"include_cards", cards}, query),
    do: query |> where([_sd, _s, d], fragment("? @> ?", d.cards, ^cards))

  defp compose_streamer_deck_query({"exclude_cards", []}, query), do: query

  defp compose_streamer_deck_query({"exclude_cards", cards}, query),
    do: query |> where([_sd, _s, d], fragment("NOT(? && ?)", d.cards, ^cards))

  defp compose_streamer_deck_query({"hsreplay_archetype", []}, query), do: query

  defp compose_streamer_deck_query({"hsreplay_archetype", archetypes}, query),
    do: query |> where([_sd, _s, d], d.hsreplay_archetype in ^archetypes)

  defp compose_streamer_deck_query({"format", format}, query),
    do: query |> where([_sd, _s, d], d.format == ^format)

  defp compose_streamer_deck_query({"best_legend_rank", legend}, query),
    do: query |> where([sd], sd.best_legend_rank > 0 and sd.best_legend_rank <= ^legend)

  defp compose_streamer_deck_query({"latest_legend_rank", legend}, query),
    do: query |> where([sd], sd.latest_legend_rank > 0 and sd.latest_legend_rank <= ^legend)

  defp compose_streamer_deck_query({"worst_legend_rank", legend}, query),
    do: query |> where([sd], sd.worst_legend_rank > 0 and sd.worst_legend_rank <= ^legend)

  defp compose_streamer_deck_query({"deck_id", deck_id}, query),
    do: query |> where([_sd, _s, d], d.id == ^deck_id)

  defp compose_streamer_deck_query({"min_minutes_played", min_minutes_played}, query),
    do: query |> where([sd, _s, _d], sd.minutes_played >= ^min_minutes_played)

  defp compose_streamer_deck_query(
         {"last_played", <<"min_ago_"::binary, min_ago::bitstring>>},
         query
       ) do
    min_ago
    |> Integer.parse()
    |> case do
      {num, _} -> query |> where([sd, _s, _d], sd.last_played >= ago(^num, "minute"))
      _ -> query
    end
  end

  defp compose_streamer_deck_query(
         {"first_played", <<"min_ago_"::binary, min_ago::bitstring>>},
         query
       ) do
    min_ago
    |> Integer.parse()
    |> case do
      {num, _} -> query |> where([sd, _s, _d], sd.first_played >= ago(^num, "minute"))
      _ -> query
    end
  end

  defp compose_streamer_deck_query(_unrecognized, query), do: query
end
