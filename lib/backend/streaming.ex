defmodule Backend.Streaming do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.HSReplay
  alias Backend.Streaming.Streamer
  alias Backend.Streaming.StreamerDeck

  def relevant_bnet_game_type?(%{game_type: bnet_game_type}) do
    [10, 9, 10, 31, 1, 2, 45, 30, 4] |> Enum.member?(bnet_game_type)
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

  def get_streamers_decks(twitch_login) do
    query =
      from sd in StreamerDeck,
        join: s in assoc(sd, :streamer),
        join: d in assoc(sd, :deck),
        preload: [streamer: s, deck: d],
        select: sd,
        order_by: [desc: sd.last_played],
        where: s.twitch_login == ^twitch_login

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
           do: get_or_create_streamer_deck(deck, streamer, sn.rank, sn.legend_rank)
    end)
  end

  def get_or_create_streamer(twitch_login, twitch_display, twitch_id) do
    query =
      from s in Streamer,
        where: s.twitch_id == ^twitch_id,
        select: s

    query
    |> Repo.one()
    |> case do
      nil -> create_streamer(twitch_login, twitch_display, twitch_id)
      s -> {:ok, s}
    end
  end

  def create_streamer(twitch_login, twitch_display, twitch_id) do
    attrs = %{twitch_login: twitch_login, twitch_display: twitch_display, twitch_id: twitch_id}

    %Streamer{}
    |> Streamer.changeset(attrs)
    |> Repo.insert()
  end

  def get_or_create_streamer_deck(deck, streamer, rank, legend_rank) do
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
      nil -> create_streamer_deck(deck, streamer, rank, legend_rank)
      sd -> update_streamer_deck(sd, rank, legend_rank)
    end
  end

  def create_streamer_deck(deck, streamer, rank, legend_rank) do
    now = DateTime.utc_now()

    attrs = %{
      deck: deck,
      streamer: streamer,
      best_rank: rank,
      best_legend_rank: legend_rank,
      first_played: now,
      last_played: now
    }

    %StreamerDeck{}
    |> StreamerDeck.changeset(attrs)
    |> Repo.insert()
  end

  def update_streamer_deck(ds = %StreamerDeck{}, rank, legend_rank) do
    attrs = %{
      best_rank: Enum.min([rank, ds.best_rank]),
      best_legend_rank: Enum.min([legend_rank, ds.best_legend_rank]),
      last_played: NaiveDateTime.utc_now()
    }

    ds
    |> StreamerDeck.changeset(attrs)
    |> Repo.update()
  end

  def change_deck_association() do
    streamer_decks([])
    |> Enum.reduce(Multi.new(), fn sd, multi ->
      old_id = sd.deck.id
      deckcode = Backend.Hearthstone.Deck.deckcode(sd.deck)
      uniq = to_string(sd.streamer_id) <> deckcode

      case Backend.Hearthstone.decks([{"deckcode", deckcode}]) do
        [deck = %{id: id}] when id != old_id ->
          case streamer_decks([{"deck_id", id}]) do
            [other_sd] ->
              attrs = %{
                best_rank: Enum.min([other_sd.best_rank, sd.best_rank]),
                best_legend_rank: Enum.min([other_sd.best_rank, sd.best_legend_rank]),
                last_played:
                  if(NaiveDateTime.compare(other_sd.last_played, sd.last_played) == :lt,
                    do: sd.last_played,
                    else: other_sd.last_played
                  )
              }

              cs =
                other_sd
                |> StreamerDeck.changeset(attrs)

              Multi.update(multi, uniq, cs)
              Multi.delete(multi, uniq <> "delete", sd)

            _ ->
              cs =
                sd
                |> StreamerDeck.changeset(%{deck_id: deck.id})
                |> Ecto.Changeset.unique_constraint(:name)

              Multi.update(
                multi,
                uniq,
                cs
              )
          end

        _ ->
          multi
      end
    end)
    |> Repo.transaction()
  end

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

  defp compose_streamer_deck_query({"twitch_login", twitch_login}, query) do
    query
    |> join(:inner, [sd], s in assoc(sd, :streamer))
    |> where([_sd, s, _d], s.twitch_login == ^twitch_login)
  end

  defp compose_streamer_deck_query({"order_by", {direction, field}}, query) do
    query
    |> order_by([{^direction, ^field}])
  end

  defp compose_streamer_deck_query({"limit", limit}, query), do: query |> limit(^limit)

  defp compose_streamer_deck_query({"class", class}, query),
    do: query |> where([_sd, _s, d], d.class == ^class)

  defp compose_streamer_deck_query({"format", format}, query),
    do: query |> where([_sd, _s, d], d.format == ^format)

  defp compose_streamer_deck_query({"legend", legend}, query),
    do: query |> where([sd], sd.best_legend_rank > 0 and sd.best_legend_rank <= ^legend)

  defp compose_streamer_deck_query({"deck_id", deck_id}, query),
    do: query |> where([_sd, _s, d], d.id == ^deck_id)

  defp compose_streamer_deck_query(_unrecognized, query), do: query
end
