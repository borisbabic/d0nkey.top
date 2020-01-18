defmodule Backend.Infrastructure.BattlefyCommunicator do
  require Logger
  alias Backend.Battlefy
  alias Backend.Blizzard
  @behaviour Backend.Battlefy.Communicator
  defp get_latest_tuesday() do
    %{year: year, month: month, day: day} = now = NaiveDateTime.utc_now()
    day_of_the_week = :calendar.day_of_the_week(year, month, day)
    days_to_subtract = 0 - rem(day_of_the_week + 5, 7)
    NaiveDateTime.add(now, days_to_subtract * 24 * 60 * 60, :second)
  end

  @spec get_masters_date_range(:week) :: {NaiveDateTime.t(), NaiveDateTime.t()}
  defp get_masters_date_range(:week) do
    start_time = get_latest_tuesday()
    end_time = NaiveDateTime.add(start_time, 7 * 24 * 60 * 60, :second)
    {start_time, end_time}
  end

  def get_masters_qualifiers() do
    {start_time, end_time} = get_masters_date_range(:week)
    get_masters_qualifiers(start_time, end_time)
  end

  def get_masters_qualifiers(start_time, end_time) do
    url =
      "https://majestic.battlefy.com/hearthstone-masters/tournaments?start=#{
        NaiveDateTime.to_iso8601(start_time)
      }&end=#{NaiveDateTime.to_iso8601(end_time)}"

    {uSecs, response} = :timer.tc(&HTTPoison.get!/1, [url])
    Logger.debug("Got masters qualifiers in #{div(uSecs, 1000)} ms")

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
  def get_invited_players(tour_stop) do
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
end
