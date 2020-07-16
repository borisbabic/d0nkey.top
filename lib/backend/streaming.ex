defmodule Backend.Streaming do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Backend.HSReplay
  alias Backend.Streaming.Streamer
  alias Backend.Streaming.StreamerDeck

  def relevant_bnet_game_type?(%{game_type: bnet_game_type}) do
    [10, 9, 10, 31, 1, 2, 45, 30, 4] |> Enum.member?(bnet_game_type)
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
end
