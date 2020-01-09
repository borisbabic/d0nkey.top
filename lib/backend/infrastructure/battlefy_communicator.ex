defmodule Backend.Infrastructure.BattlefyCommunicator do
  @behaviour Backend.MastersTour.BattlefyCommunicator
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

    response = HTTPoison.get!(url)

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

  def get_invited_players(tour_stop \\ nil) do
    url =
      case tour_stop do
        ts when is_binary(ts) ->
          "https://majestic.battlefy.com/hearthstone-masters/invitees?tourStop=#{ts}"

        nil ->
          "https://majestic.battlefy.com/hearthstone-masters/invitees"
      end

    response = HTTPoison.get!(url)

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
end
