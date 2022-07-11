defmodule Backend.PonyDojo do
  @moduledoc false
  use GenServer

  alias Backend.Grandmasters.PromotionCalculator
  alias Backend.MastersTour
  alias Backend.TournamentStats.TeamStats
  alias Backend.TournamentStats.TournamentTeamStats

  @type points :: %{
          qualified: integer(),
          wins: integer(),
          worlds: integer()
        }
  @type player :: %{
          battletag: String.t(),
          image_url: String.t(),
          worlds_points: integer(),
          points: points(),
          world_champ?: boolean()
        }
  @csv_url "https://docs.google.com/spreadsheets/d/1B0xz1JmSYoD_a61q_nS9w6g0u10gZMYsbgo2etAuRlU/export?gid=0&format=csv"
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(_args) do
    {:ok, %{players: []}, {:continue, :init}}
  end

  def handle_continue(:init, old_state) do
    new_state =
      case create_state() do
        {:ok, state} -> state
        _ -> old_state
      end

    {:noreply, new_state}
  end

  def update(), do: GenServer.cast(__MODULE__, :update)

  def players(), do: GenServer.call(__MODULE__, :players)

  def handle_call(:players, _from, state = %{players: players}), do: {:reply, players, state}

  def handle_cast(:update, old_state) do
    new_state =
      case create_state() do
        {:ok, s} -> s
        _ -> old_state
      end

    {:noreply, new_state}
  end

  @spec create_state() :: {:ok, [player()]} | {:error, any()}
  def create_state() do
    with {:ok, %{body: body}} <- HTTPoison.get(@csv_url, [], follow_redirect: true) do
      players =
        body
        |> create_players()
        |> calculate_points()
        |> sort()

      {:ok, %{players: players}}
    end
  end

  defp create_players(body) do
    body
    |> String.split(["\n", "\r\n"])
    |> Enum.drop(1)
    |> Enum.map(fn line ->
      [btag, image_url, points_raw | _] = String.split(line, ",")
      points = Util.to_int(points_raw, 0)

      %{
        battletag: btag,
        image_url: image_url,
        worlds_points: points,
        world_champ?: champ?(points)
      }
    end)
  end

  def calculate_points(players) do
    mts = latest_six_mts()
    promotion_points = promotion_points(mts)

    mt_stats =
      mts
      |> Backend.MastersTour.masters_tours_stats()
      |> Backend.TournamentStats.create_team_stats_collection(&MastersTour.fix_name/1)

    invited_num = invited_counts(mts)

    Enum.map(players, fn p ->
      invited = 2000 * Map.get(invited_num, p.battletag, 0)

      wins =
        2000 *
          Enum.find_value(mt_stats, 0, fn {short, tts} ->
            with true <- same(p.battletag, short) do
              tts
              |> Enum.map(&TournamentTeamStats.total_stats/1)
              |> TeamStats.calculate_team_stats()
              |> Map.get(:wins)
            end
          end)

      Map.put(p, :points, %{
        qualified: invited,
        wins: wins,
        worlds: p.worlds_points
      })
    end)
  end

  defp same(player_one, player_two) do
    MastersTour.fix_name(player_one) == MastersTour.fix_name(player_two)
  end

  def invited_counts(mts) do
    mts
    |> Enum.flat_map(fn %{id: id} ->
      id
      |> Backend.MastersTour.list_invited_players()
      |> Enum.map(& &1.battletag_full)
      |> Enum.uniq()
    end)
    |> Enum.frequencies()
  end

  defp promotion_points(mts) do
    mts
    |> Enum.flat_map(&PromotionCalculator.ts_points(&1.id, :points_2021))
    |> PromotionCalculator.group_ts_rankings()
  end

  def latest_six_mts() do
    now = NaiveDateTime.utc_now()

    Backend.MastersTour.TourStop.all()
    |> Enum.reverse()
    |> Enum.drop_while(fn %{start_time: st} ->
      !st || :lt == NaiveDateTime.compare(now, st)
    end)
    |> Enum.take(6)
    |> Enum.reverse()
  end

  def champ?(points), do: points > 90_000

  def total(%{points: points}), do: total(points)
  def total(%{qualified: q, wins: s, worlds: w}), do: q + s + w
  def total(_), do: 0

  defp sort(players), do: Enum.sort(players, &sorter/2)

  defp sorter(%{world_champ?: true}, _), do: true
  defp sorter(_, %{world_champ?: true}), do: false
  defp sorter(left, right), do: total(left) > total(right)
end
