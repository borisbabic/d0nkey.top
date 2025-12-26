defmodule Backend.Reporting do
  @moduledoc "Reporting and alarms"
  import Ecto.Query
  alias Backend.Repo
  alias Hearthstone.DeckTracker.Game

  def check_game_count() do
    threshold = Application.fetch_env!(:backend, :five_min_game_threshold)
    five_min_ago = DateTime.utc_now() |> DateTime.shift(minute: -5)
    query = from g in Game, where: g.inserted_at >= ^five_min_ago
    count = Repo.aggregate(query, :count)

    if count < threshold do
      Bot.MessageHandlerUtil.send_reporting_message(
        "Too few games received in the last 5 minutes! Received: #{count} | Threshold: #{threshold}"
      )
    else
      Bot.MessageHandlerUtil.send_muted_reporting_message(
        "Sufficient games received in the last 5 minutes! Received: #{count} | Threshold: #{threshold}"
      )
    end
  end

  def check_oban_insert_available_count() do
    threshold = Application.get_env(:backend, :available_game_insert_threshold)

    if threshold do
      query =
        from oj in "oban_jobs", where: oj.state == "available" and oj.queue == "hs_game_inserter"

      count = Repo.aggregate(query, :count)

      if count > threshold do
        Bot.MessageHandlerUtil.send_reporting_message("Too many games in queue! #{count}")
      else
        Bot.MessageHandlerUtil.send_muted_reporting_message(
          "Not too many games in queue! #{count}"
        )
      end
    end
  end

  def check_last_aggregated(force_check \\ false) do
    if force_check || Application.get_env(:backend, :check_last_aggregated) do
      case Hearthstone.DeckTracker.aggregated_periods_formats_time() do
        [] ->
          Bot.MessageHandlerUtil.send_reporting_message("NOTHING IS AGGREGATED @d0nkey!!!!!!")

        pft ->
          {period, format, time} = Enum.max_by(pft, fn {_, _, time} -> time end, NaiveDateTime)
          diff = NaiveDateTime.diff(NaiveDateTime.utc_now(), time, :minute)
          message = "Last aggregation was #{period} #{format} - #{diff} minutes ago"

          if diff > 120 do
            Bot.MessageHandlerUtil.send_reporting_message(message)
          else
            Bot.MessageHandlerUtil.send_muted_reporting_message(message)
          end
      end
    end
  end
end
