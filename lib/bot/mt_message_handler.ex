defmodule Bot.MTMessageHandler do
  @moduledoc false
  import Bot.MessageHandlerUtil
  alias Backend.MastersTour
  alias Backend.MastersTour.TourStop
  require Logger

  def handle_mt_standings(msg = %{content: content}) do
    content
    |> get_options(:string)
    |> TourStop.get()
    |> or_current_mt()
    |> mt_message(msg)
    |> send_or_travolta(msg.channel_id)
  end

  def mt_message(ts = %{battlefy_id: battlefy_id}, message) when is_binary(battlefy_id) do
    Logger.debug("Getting mt message for #{ts.id} #{battlefy_id} ")

    with %{stages: [s | _]} <- MastersTour.get_mt_tournament(ts),
         standings <- MastersTour.get_mt_stage_standings(s, ts),
         battletags = [_ | _] <- get_guild_battletags!(message.guild_id) do
      Bot.BattlefyMessageHandler.create_message(battletags, standings, &MastersTour.fix_name/1)
    else
      other ->
        Logger.debug("Unable to create standings message: #{inspect(other)}")
        ""
    end
  end

  def mt_message(_, _), do: ""

  defp or_current_mt(mt = %{id: _}), do: mt
  defp or_current_mt(_), do: TourStop.get_current(1, 240) |> TourStop.get()

  def handle_qualifier_standings(msg = %{content: content}) do
    with {num, _} <- content |> get_options(:string) |> Integer.parse(),
         %{id: id} <- MastersTour.get_qualifier(num) do
      Bot.BattlefyMessageHandler.handle_tournament_standings(id, msg)
    else
      _ ->
        recent_qualifier_standings(msg)
    end
  end

  def standings_message(guild_id, num) when is_integer(num) do
    with %{id: id} <- MastersTour.get_qualifier(num),
         {:ok, msg} <-
           Bot.BattlefyMessageHandler.create_standings_message(id, %{guild_id: guild_id}) do
      msg
    else
      _ -> standings_message(guild_id)
    end
  end

  def standings_message(guild_id, _), do: standings_message(guild_id)

  def standings_message(_guild_id) do
    base_message =
      MastersTour.get_recent_qualifiers()
      |> Enum.map(fn q ->
        num = Backend.MastersTour.Qualifier.num(q)
        title = "MTQ #{num}"

        standings = Backend.Battlefy.get_standings(q.id) |> Backend.Battlefy.sort_standings()
        rows = Bot.BattlefyMessageHandler.create_message_cells(standings)

        case rows do
          [] -> nil
          _ -> TableRex.quick_render!(rows, [], title)
        end
      end)
      |> Enum.filter(& &1)
      |> Enum.join("\n")

    """
    ```
    #{base_message}
    ```
    """
  end

  def recent_qualifier_standings(msg = %{guild_id: guild_id}) do
    message = standings_message(guild_id)
    send_or_travolta(message, msg.channel_id)
  end
end
