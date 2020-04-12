defmodule Backend.Infrastructure.BattlefyCommunicator do
  @moduledoc false
  require Logger
  alias Backend.Battlefy
  alias Backend.Blizzard
  alias Backend.Battlefy.Match
  alias Backend.Battlefy.MatchDeckstrings
  alias Backend.Battlefy.Profile
  alias Backend.Battlefy.Tournament
  import Backend.Infrastructure.CommunicatorUtil
  @behaviour Backend.Battlefy.Communicator

  @doc """
  Get's the qualifiers that start between the start and end_date (inclusive)
  """
  def get_masters_qualifiers(start_date, end_date) do
    {:ok, end_time} = NaiveDateTime.new(end_date.year, end_date.month, end_date.day, 23, 59, 59)

    url =
      "https://majestic.battlefy.com/hearthstone-masters/tournaments?start=#{
        Date.to_iso8601(start_date)
      }&end=#{NaiveDateTime.to_iso8601(end_time)}"

    {u_secs, response} = :timer.tc(&HTTPoison.get!/1, [url])
    Logger.info("Got masters qualifiers #{url} in #{div(u_secs, 1000)} ms")

    Poison.decode!(response.body)
    |> Enum.map(fn %{
                     "startTime" => start_time,
                     "name" => name,
                     "slug" => slug,
                     "region" => region,
                     "_id" => id
                   } ->
      %{
        start_time: elem(NaiveDateTime.from_iso8601(start_time), 1),
        name: name,
        region: region,
        id: id,
        slug: slug
      }
    end)
  end

  @spec get_invited_players(Blizzard.tour_stop() | String.t() | nil) :: Battlefy.invited_player()
  def get_invited_players(tour_stop \\ nil) do
    url =
      case tour_stop do
        nil -> "https://majestic.battlefy.com/hearthstone-masters/invitees"
        ts -> "https://majestic.battlefy.com/hearthstone-masters/invitees?tourStop=#{ts}"
      end

    {u_secs, response} = :timer.tc(&HTTPoison.get!/1, [URI.encode(url)])

    Logger.info(
      "Got invited players #{tour_stop && "for #{tour_stop} "}in #{div(u_secs, 1000)} ms"
    )

    Poison.decode!(response.body)
    |> Enum.map(
      fn invited = %{
           "battletag" => battletag_full,
           "type" => type,
           "tourStop" => tour_stop,
           "createdAt" => upstream_time
         } ->
        %{
          battletag_full: battletag_full,
          reason: invited["reason"] || type,
          type: type,
          tour_stop: tour_stop,
          upstream_time: elem(NaiveDateTime.from_iso8601(upstream_time), 1),
          tournament_slug: invited["tournamentSlug"],
          tournament_id: invited["tournamentID"]
        }
      end
    )
  end

  @spec get_stage(Backend.Battlefy.stage_id()) :: Backend.Battlefy.Stagea.t()
  def get_stage(stage_id) do
    url = "https://api.battlefy.com/stages/#{stage_id}"

    get_body(url)
    |> Poison.decode!()
    |> Backend.Battlefy.Stage.from_raw_map()
  end

  @spec get_standings(Backend.Battlefy.stage_id()) :: [Backend.Battlefy.Standings.t()]
  def get_standings(stage_id) do
    url = "https://api.battlefy.com/stages/#{stage_id}/standings"

    get_body(url)
    |> Poison.decode!()
    |> Backend.Battlefy.Standings.from_raw_map_list()
  end

  @spec get_round_standings(Backend.Battlefy.stage_id(), integer | String.t()) :: [
          Backend.Battlefy.Standings.t()
        ]
  def get_round_standings(stage_id, round) do
    url = "https://api.battlefy.com/stages/#{stage_id}/rounds/#{round}/standings"

    get_body(url)
    |> Poison.decode!()
    |> Backend.Battlefy.Standings.from_raw_map_list()
  end

  @spec get_tournament(Backend.Battlefy.tournament_id()) :: Backend.Battlefy.Tournament.t()
  def get_tournament(tournament_id) do
    url =
      "https://dtmwra1jsgyb0.cloudfront.net/tournaments/#{tournament_id}?extend[stages]=true&extend[organization]=true"

    get_body(url)
    |> Poison.decode!()
    |> Enum.at(0)
    |> Backend.Battlefy.Tournament.from_raw_map()
  end

  @spec get_matches(Battlefy.stage_id(), Battlefy.get_matches_options()) :: [Match.t()]
  def get_matches(stage_id, opts \\ []) do
    url =
      case opts[:round] do
        nil -> "http://api.battlefy.com/stages/#{stage_id}/matches"
        round -> "http://api.battlefy.com/stages/#{stage_id}/matches?roundNumber=#{round}"
      end

    get_body(url)
    |> Poison.decode!()
    |> Enum.map(&Match.from_raw_map/1)
  end

  @spec get_match_deckstrings(Battlefy.tournament_id(), Battlefy.match_id()) :: [
          MatchDeckstrings.t()
        ]
  def get_match_deckstrings(tournament_id, match_id) do
    url =
      "https://majestic.battlefy.com/tournaments/#{tournament_id}/matches/#{match_id}/deckstrings"

    get_body(url)
    |> Poison.decode!()
    |> MatchDeckstrings.from_raw_map()
  end

  def get_profile(slug) do
    url = "https://api.battlefy.com/profile/#{slug}"

    get_body(url)
    |> Poison.decode!()
    |> Profile.from_raw_map()
  end

  @spec get_user_tournaments(String.t()) :: [Tournament.t()]
  def get_user_tournaments(slug) do
    # they return max 25 regardless of size. I don't feel like paginating or being smart about it
    url = "https://search.battlefy.com/user/#{slug}/tournaments?size=1000"

    raw =
      get_body(url)
      |> Poison.decode!()

    raw["tournaments"]
    |> Enum.map(&Tournament.from_raw_map/1)
  end
end
