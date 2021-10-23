defmodule Command.FantasyMTFixer do
  @moduledoc "Fix MT fantasy battletag issues using the spreadhseet"
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.Fantasy.LeagueTeamPick
  alias Backend.Battlefy
  alias Backend.MastersTour.TourStop

  def get_changes(document_url) do
    %{body: body} = HTTPoison.get!(document_url, [], follow_redirect: true)

    body
    |> String.split(["\n", "\r\n"])
    |> Enum.flat_map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(&(&1 =~ "#"))
      |> case do
        [old, new] when old != new -> [{old, new}]
        _ -> []
      end
    end)
  end

  def get_url!(:Silvermoon),
    do:
      "https://docs.google.com/spreadsheets/d/1uo6B4ABU_rPU6jcForpUccwdI49xhhYD6-rKw0h6EHo/export?gid=0&format=csv"

  def fix(mt), do: mt |> get_url!() |> fix(mt)

  def fix(url, mt) do
    url
    |> get_changes()
    |> apply_changes(mt)
  end

  def fix_from_participants(mt) do
    mt
    |> get_participants_changes()
    |> apply_changes(mt)
  end

  def get_participants_changes(mt) do
    mt
    |> TourStop.get_battlefy_id!()
    |> Battlefy.get_participants()
    |> Enum.flat_map(fn
        %{name: new, players: [%{in_game_name: old}]} -> [{old, new}]
        _ -> []
      end)
  end
  def apply_changes(changes, mt) do
    tour_stop = to_string(mt)

    changes
    |> Enum.reduce(Multi.new(), fn {old, new}, multi ->
      query =
        from ltp in LeagueTeamPick,
          join: lt in assoc(ltp, :team),
          join: l in assoc(lt, :league),
          where: l.competition == ^tour_stop and ltp.pick == ^old

      multi
      |> Multi.update_all("#{new}_#{old}", query, set: [pick: new])
    end)
    |> Repo.transaction()
  end
end
