defmodule Bot.MTMessageHandler do
  @moduledoc false
  import Bot.MessageHandlerUtil
  alias Backend.MastersTour

  def handle_qualifier_standings(msg = %{content: content}) do
    with {num, _} <- content |> get_options(:string) |> Integer.parse(),
         %{id: id} <- MastersTour.get_qualifier(num) do
      Bot.BattlefyMessageHandler.handle_tournament_standings(id, msg)
    else
      _ ->
        recent_qualifier_standings(msg)
    end
  end

  def recent_qualifier_standings(msg = %{guild_id: guild_id}) do
    battletags = get_guild_battletags!(guild_id)
    base_message = MastersTour.get_recent_qualifiers()
    |> Enum.map(fn q ->
      num = Backend.MastersTour.Qualifier.num(q)
      title = "MTQ #{num}"

      standings = Backend.Battlefy.get_standings(q.id)
      rows = Bot.BattlefyMessageHandler.create_message_cells(battletags, standings)
      case rows do
        [] -> nil
        _ -> TableRex.quick_render!(rows, [], title)
      end
    end)
    |> Enum.filter(& &1)
    |> Enum.join("\n")

    message = """
    ```
    #{base_message}
    ```
    """

    send_message(message, msg.channel_id)
  end
end
