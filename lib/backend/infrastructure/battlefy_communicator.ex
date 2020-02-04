defmodule Backend.Infrastructure.BattlefyCommunicator do
  require Logger
  alias Backend.Battlefy
  alias Backend.Blizzard
  alias Backend.Battlefy.Match
  alias Backend.Battlefy.MatchDeckstrings
  @behaviour Backend.Battlefy.Communicator

  def get_masters_qualifiers(start_time, end_time) do
    url =
      "https://majestic.battlefy.com/hearthstone-masters/tournaments?start=#{
        Date.to_iso8601(start_time)
      }&end=#{Date.to_iso8601(end_time)}"

    {uSecs, response} = :timer.tc(&HTTPoison.get!/1, [url])
    Logger.debug("Got masters qualifiers #{url} in #{div(uSecs, 1000)} ms")

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

    {uSecs, response} = :timer.tc(&HTTPoison.get!/1, [URI.encode(url)])

    Logger.debug(
      "Got invited players #{tour_stop && "for #{tour_stop} "}in #{div(uSecs, 1000)} ms"
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

  @spec get_standings(Backend.Battlefy.stage_id()) :: [Backend.Battlefy.Standings.t()]
  def get_standings(stage_id) do
    url = "https://api.battlefy.com/stages/#{stage_id}/standings"

    {uSecs, response} = :timer.tc(&HTTPoison.get!/1, [URI.encode(url)])

    Logger.debug("Got #{url} in #{div(uSecs, 1000)} ms")

    Poison.decode!(response.body)
    |> Enum.map(&Backend.Battlefy.Standings.from_raw_map/1)
  end

  @spec get_tournament(Backend.Battlefy.tournament_id()) :: Backend.Battlefy.Tournament.t()
  def get_tournament(tournament_id) do
    url = "https://majestic.battlefy.com/tournaments/#{tournament_id}"

    {uSecs, response} = :timer.tc(&HTTPoison.get!/1, [URI.encode(url)])

    Logger.debug("Got #{url} in #{div(uSecs, 1000)} ms")

    Poison.decode!(response.body)
    |> Backend.Battlefy.Tournament.from_raw_map()
  end

  @spec get_matches(Battlefy.stage_id(), Battlefy.get_matches_options()) :: [Match.t()]
  def get_matches(stage_id, opts \\ []) do
    url =
      case opts[:round] do
        nil -> "http://api.battlefy.com/stages/#{stage_id}/matches"
        round -> "http://api.battlefy.com/stages/#{stage_id}/matches?roundNumber=#{round}"
      end

    {uSecs, response} = :timer.tc(&HTTPoison.get!/1, [URI.encode(url)])

    Logger.debug("Got #{url} in #{div(uSecs, 1000)} ms")

    Poison.decode!(response.body)
    |> Enum.map(&Match.from_raw_map/1)
  end

  @spec get_match_deckstrings(Battlefy.tournament_id(), Battlefy.match_id()) :: [
          MatchDeckstrings.t()
        ]
  def get_match_deckstrings(tournament_id, match_id) do
    url =
      "https://majestic.battlefy.com/tournaments/#{tournament_id}/matches/#{match_id}/deckstrings"

    {uSecs, response} = :timer.tc(&HTTPoison.get!/1, [URI.encode(url)])

    Logger.debug("Got #{url} in #{div(uSecs, 1000)} ms")

    Poison.decode!(response.body)
    |> MatchDeckstrings.from_raw_map()
  end
end
