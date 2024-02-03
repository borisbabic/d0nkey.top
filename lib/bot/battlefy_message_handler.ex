defmodule Bot.BattlefyMessageHandler do
  @moduledoc false
  alias Nostrum.Api
  alias Backend.Battlefy
  import Bot.MessageHandlerUtil
  require Logger

  def handle_tournament_standings(message = %{content: content}),
    do:
      content
      |> get_options(:string)
      |> String.trim()
      |> handle_tournament_standings(message)

  def handle_tournament_standings(battlefy_id, message) when is_binary(battlefy_id) do
    create_standings_message(battlefy_id, message)
    |> send_message(message)
  end

  def handle_tournament_standings(standings, %{channel_id: channel_id, guild_id: guild_id})
      when is_list(standings) do
    message =
      guild_id
      |> get_guild_battletags!()
      |> create_message(standings)

    Api.create_message(channel_id, message)
  end

  def create_standings_message(battlefy_id, message, battletags \\ [])

  def create_standings_message(
        battlefy_id,
        _message = %{guild_id: _guild_id},
        [_ | _] = battletags
      ) do
    case Battlefy.get_standings(battlefy_id) do
      unsorted when is_list(unsorted) ->
        standings = Battlefy.sort_standings(unsorted)
        {:ok, create_message(battletags, standings)}

      other ->
        log_unable_to_create(other)
    end
  end

  def create_standings_message(battlefy_id, message = %{guild_id: guild_id}, _battletags) do
    case get_guild_battletags!(guild_id) do
      [_ | _] = battletags -> create_standings_message(battlefy_id, message, battletags)
      other -> log_unable_to_create(other)
    end
  end

  defp log_unable_to_create(other) do
    Logger.warn("Unable to create standings message: #{inspect(other)}")
    {:error, :could_not_create_message}
  end

  @spec create_message([String.t()], [Battlefy.Standings.t()], (name :: String.t() -> String.t())) ::
          String.t()
  def create_message(battletags, standings, name_mapper \\ & &1) do
    mapped = Enum.map(battletags, name_mapper)

    standings
    |> Enum.filter(&(&1.team && name_mapper.(&1.team.name) in mapped))
    |> create_message()
  end

  @spec create_message([Battlefy.Standings.t()]) :: String.t()
  def create_message(standings) do
    create_message_cells(standings)
    |> Enum.map_join("\n", &cells_to_msg/1)
  end

  def cells_to_msg(cells), do: Enum.join(cells, " ")

  def create_message_cells(standings) do
    standings
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
