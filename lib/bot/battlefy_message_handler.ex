defmodule Bot.BattlefyMessageHandler do
  @moduledoc false
  alias Nostrum.Api
  alias Backend.Battlefy
  import Bot.MessageHandlerUtil

  def handle_tournament_standings(message = %{content: content}),
    do:
      content
      |> get_options(:string)
      |> handle_tournament_standings(message)

  def handle_tournament_standings(battlefy_id, message) when is_binary(battlefy_id) do
    create_standings_message(battlefy_id, message)
    |> send_message(message)
  end

  def create_standings_message(battlefy_id, _message = %{guild_id: guild_id}) do
    with standings = [_|_] <- Battlefy.get_standings(battlefy_id),
         battletags = [_|_] <- get_guild_battletags!(guild_id) do
          {:ok, create_message(battletags, standings)}
    else
      _ -> {:error, :could_not_create_message}
    end
  end

  def handle_tournament_standings(standings, %{channel_id: channel_id, guild_id: guild_id})
      when is_list(standings) do
    message =
      guild_id
      |> get_guild_battletags!()
      |> create_message(standings)

    Api.create_message(channel_id, message)
  end

  @spec create_message([String.t()], [Battlefy.Standings.t()]) :: String.t()
  def create_message(battletags, standings) do
    create_message_cells(battletags, standings)
    |> Enum.map_join("\n", &cells_to_msg/1)
  end

  def cells_to_msg(cells), do: Enum.join(cells, " ")

  def create_message_cells(battletags, standings) do
    standings
    |> Enum.filter(&(&1.team && &1.team.name in battletags))
    |> Enum.map(fn s ->
      score =
        if s.wins && s.losses do
          "#{s.wins} - #{s.losses}"
        else
          s.place
        end
      [score, s.team.name]
    end)
  end
end
