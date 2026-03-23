defmodule Command.PlayerInfoImporter do
  @moduledoc false
  alias Backend.Battlefy
  alias Backend.Battlefy.Team
  alias Backend.Battlenet.Battletag

  def add_missing_from_battlefy(
        battlefy_tournament_id,
        country_or_region,
        comment,
        reported_by \\ nil,
        priority \\ 4000
      ) do
    teams = Battlefy.get_participants(battlefy_tournament_id)

    reported_by =
      with nil <- reported_by do
        __MODULE__ |> to_string() |> String.split(".") |> Enum.at(-1)
      end

    for team <- teams,
        name = Team.player_or_team_name(team),
        is_binary(name),
        attr_field = attr_field(name),
        nil == Backend.PlayerInfo.get_region(name) do
      attrs =
        %{
          country: country_or_region,
          comment: comment,
          priority: priority,
          reported_by: reported_by
        }
        |> Map.put(attr_field, name)

      Backend.Battlenet.create_battletag(attrs)
    end
  end

  defp attr_field(battletag) do
    cond do
      Battletag.long?(battletag) -> :battletag_full
      Battletag.short?(battletag) -> :battletag_short
      true -> nil
    end
  end
end
