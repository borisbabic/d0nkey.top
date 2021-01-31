defmodule Backend.MastersTour do
  @moduledoc """
    The MastersTour context.
  """
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.MastersTour.Qualifier
  alias Backend.MastersTour.PlayerStats
  alias Backend.MastersTour.PlayerNationality
  alias Backend.MastersTour.TourStop
  alias Backend.Infrastructure.BattlefyCommunicator
  alias Backend.Infrastructure.PlayerStatsCache
  alias Backend.Infrastructure.PlayerNationalityCache
  alias Backend.Blizzard
  alias Backend.Battlefy
  alias Backend.TournamentStats.TournamentTeamStats

  @type gm_money_rankings :: [{String.t(), integer, [{Blizzard.tour_stop(), integer}]}]
  @type user_signup_options :: %{
          user_id: Battlefy.user_id(),
          token: String.t(),
          battletag_full: Blizzard.battletag(),
          battlenet_id: String.t(),
          discord: String.t(),
          regions: [Blizzard.region()],
          slug: String.t()
        }

  def create_invited_player(attrs \\ %{}) do
    %InvitedPlayer{}
    |> InvitedPlayer.changeset(attrs)
  end

  def list_invited_players() do
    Repo.all(InvitedPlayer)
  end

  def list_invited_players(tour_stop) do
    query =
      from ip in InvitedPlayer,
        where: ip.tour_stop == ^to_string(tour_stop),
        select: ip,
        order_by: [desc: ip.upstream_time]

    Repo.all(query)
  end

  def filter_existing(invited_players, tour_stop) do
    existing =
      Repo.all(
        from ip in InvitedPlayer,
          where: ip.tour_stop == ^to_string(tour_stop),
          select:
            fragment(
              "concat(?,?, CASE WHEN ?=true THEN 'true' ELSE 'false' END)",
              ip.battletag_full,
              ip.tour_stop,
              ip.official
            )
      )
      |> MapSet.new()

    invited_players
    |> Enum.filter(fn ip -> !MapSet.member?(existing, InvitedPlayer.uniq_string(ip)) end)
  end

  def has_qualifier_started?(%{start_time: st}),
    do: NaiveDateTime.compare(st, NaiveDateTime.utc_now()) == :lt

  def has_qualifier_started?(_), do: false

  @spec is_finished_qualifier?(Battlefy.Tournament.t()) :: boolean
  def is_finished_qualifier?(%{
        stages: [%{current_round: nil, has_started: true, standing_ids: [_ | _]}]
      }),
      do: true

  def is_finished_qualifier?(_), do: false

  @spec is_supported_qualifier?(Battlefy.Tournament.t()) :: boolean
  def is_supported_qualifier?(%{stages: [%{bracket: %{type: "elimination", style: "single"}}]}),
    do: true

  def is_supported_qualifier?(_), do: false

  @spec create_qualifier_standings([Battlefy.Standings.t()]) :: [Qualifier.Standings.t()]
  def create_qualifier_standings(battlefy_standings) do
    battlefy_standings
    |> Enum.map(
      fn s = %{wins: wins, losses: losses, place: position, team: %{name: battletag_full}} ->
        %{
          battletag_full: battletag_full,
          wins: wins - Map.get(s, :auto_wins, 0),
          losses: losses - Map.get(s, :auto_losses, 0),
          position: position
        }
      end
    )
    |> Enum.group_by(fn s -> s.battletag_full end)
    |> Enum.map(fn {_key, standings} -> standings |> Enum.min_by(fn s -> s.position end) end)
  end

  def warmup_stats_cache() do
    [2020]
    |> Enum.flat_map(fn y -> [y | Backend.Blizzard.get_tour_stops_for_year(y)] end)
    |> Enum.each(&Backend.MastersTour.get_player_stats/1)
  end

  def create_and_cache_stats(qualifiers, period) do
    stats = PlayerStats.create_collection(qualifiers)
    ret = {stats, Enum.count(qualifiers)}
    PlayerStatsCache.set(period, ret)
    ret
  end

  def get_player_stats(tour_stop) when is_atom(tour_stop) do
    case PlayerStatsCache.get(tour_stop) do
      nil ->
        tour_stop
        |> list_qualifiers_for_tour()
        |> create_and_cache_stats(tour_stop)

      s ->
        s
    end
  end

  def get_player_stats(year) when is_integer(year) do
    case PlayerStatsCache.get(year) do
      nil ->
        year
        |> list_qualifiers_for_year()
        |> create_and_cache_stats(year)

      s ->
        s
    end
  end

  @spec list_qualifiers_for_player(Blizzard.battletag()) :: [Qualifier]
  def list_qualifiers_for_player(battletag_full) do
    search = "%#{battletag_full}%"

    query =
      from q in Qualifier,
        select: q,
        where: like(fragment("?::text", q.standings), ^search),
        order_by: [desc: q.start_time]

    query |> Repo.all()
  end

  def list_qualifiers_in_range(start_date = %Date{}, end_date = %Date{}),
    do:
      list_qualifiers_in_range(
        start_date |> Util.day_start(:naive),
        end_date |> Util.day_end(:naive)
      )

  def list_qualifiers_in_range(start_time = %NaiveDateTime{}, end_time = %NaiveDateTime{}) do
    query =
      from q in Qualifier,
        where: q.start_time >= ^start_time and q.start_time <= ^end_time,
        select: q

    Repo.all(query)
  end

  @spec list_qualifiers_for_tour(Blizzard.tour_stop()) :: [Qualifier]
  def list_qualifiers_for_tour(tour_stop) do
    query =
      from q in Qualifier,
        where: q.tour_stop == ^to_string(tour_stop),
        select: q,
        order_by: [asc: q.start_time]

    Repo.all(query)
  end

  @spec list_qualifiers_for_year(integer) :: [Qualifier]
  def list_qualifiers_for_year(year) do
    ts = Blizzard.get_tour_stops_for_year(year) |> Enum.map(&to_string/1)

    query =
      from q in Qualifier,
        where: q.tour_stop in ^ts,
        select: q,
        order_by: [asc: q.start_time]

    Repo.all(query)
  end

  def invalidate_stats_cache(tour_stop) do
    PlayerStatsCache.delete(tour_stop)

    tour_stop
    |> TourStop.get_year()
    |> PlayerStatsCache.delete()
  end

  def qualifiers_update() do
    Blizzard.current_ladder_tour_stop()
    |> qualifiers_update()
  end

  def reset_qualifier(tour_stop) when is_atom(tour_stop) do
    Repo.delete_all(
      from q in Qualifier,
        where: q.tour_stop == ^to_string(tour_stop)
    )

    invalidate_stats_cache(tour_stop)
    qualifiers_update(tour_stop)
  end

  def qualifiers_update(tour_stop, update_cache \\ true) when is_atom(tour_stop) do
    existing =
      list_qualifiers_for_tour(tour_stop) |> Enum.map(fn q -> q.tournament_id end) |> MapSet.new()

    new =
      get_qualifiers_for_tour(tour_stop)
      |> Enum.filter(fn q -> !MapSet.member?(existing, q.id) end)
      |> Enum.filter(&has_qualifier_started?/1)
      |> Enum.map(fn q -> Battlefy.get_tournament(q.id) end)
      |> Enum.filter(&is_supported_qualifier?/1)
      |> Enum.filter(&is_finished_qualifier?/1)
      |> Enum.map(fn t = %{stages: [stage]} ->
        {t, Battlefy.create_standings_from_matches(stage)}
      end)
      |> Enum.map(fn {t, s} ->
        standings = create_qualifier_standings(s)

        winner =
          standings
          |> Enum.find_value(fn %{position: pos, battletag_full: bt} -> pos == 1 && bt end)

        %Qualifier{}
        |> Qualifier.changeset(%{
          tour_stop: to_string(tour_stop),
          start_time: t.start_time,
          end_time: t.last_completed_match_at,
          region: to_string(t.region),
          tournament_id: t.id,
          tournament_slug: t.slug,
          winner: winner,
          type: to_string(:single_elimination),
          standings: standings
        })
      end)

    new_structs = new |> Enum.map(&Ecto.Changeset.apply_changes/1)

    multi =
      new
      |> Enum.reduce(Multi.new(), fn cs, multi ->
        Multi.insert(multi, "qualifier_#{cs.changes.tournament_id}", cs)
      end)

    invalidate_stats_cache(tour_stop)

    multi |> Repo.transaction()

    invalidate_stats_cache(tour_stop)
    if update_cache, do: warmup_stats_cache()

    # we don't really care too much if this fails since they will get officially invited at some point
    # so it's okay that it's in a separate transaction
    new_structs |> save_qualifier_invites()
  end

  def save_missing_qualifier_invites(tour_stop) when is_atom(tour_stop) do
    tournament_ids =
      list_invited_players(tour_stop)
      |> Enum.filter(fn ip -> ip.tournament_id end)
      |> Enum.map(fn ip -> ip.tournament_id end)
      |> MapSet.new()

    Repo.all(
      from qs in Qualifier,
        where: qs.tour_stop == ^to_string(tour_stop)
    )
    |> Enum.filter(fn q -> !MapSet.member?(tournament_ids, q.tournament_id) end)
    |> save_qualifier_invites()
  end

  def save_qualifier_invites(qualifiers = [%{tournament_slug: _} | _]) do
    qualifiers
    |> Enum.reduce(Multi.new(), fn q, multi ->
      ip = q |> create_qualifier_invite()
      cs = ip |> create_invited_player()
      Multi.insert(multi, InvitedPlayer.uniq_string(ip), cs)
    end)
    |> Repo.transaction()
  end

  def save_qualifier_invites(_), do: []

  @spec create_qualifier_invite(Qualifier, boolean | nil) :: any()
  def create_qualifier_invite(q, official \\ false) do
    %{
      battletag_full: q.winner,
      tour_stop: to_string(q.tour_stop),
      type: "qualifier",
      reason: "qualifier",
      upstream_time: q.end_time,
      tournament_slug: q.tournament_slug,
      tournament_id: q.tournament_id,
      official: official && true
    }
  end

  def fetch(tour_stop) do
    BattlefyCommunicator.get_invited_players(tour_stop)
    |> filter_existing(tour_stop)
    |> insert_all
  end

  def fetch() do
    existing =
      Repo.all(
        from ip in InvitedPlayer,
          select:
            fragment(
              "concat(?,?, CASE WHEN ?=true THEN 'true' ELSE 'false' END)",
              ip.battletag_full,
              ip.tour_stop,
              ip.official
            )
      )
      |> MapSet.new()

    BattlefyCommunicator.get_invited_players()
    |> Enum.filter(fn ip -> !MapSet.member?(existing, InvitedPlayer.uniq_string(ip)) end)
    |> insert_all
  end

  def insert_all(new_players) do
    new_players
    |> Enum.filter(fn np -> np.battletag_full && np.tour_stop end)
    |> Enum.uniq_by(&InvitedPlayer.uniq_string/1)
    |> Enum.reduce(Multi.new(), fn np, multi ->
      changeset = create_invited_player(np)
      Multi.insert(multi, InvitedPlayer.uniq_string(np), changeset)
    end)
    |> Repo.transaction()
  end

  @spec delete_copied(Backend.Blizzard.tour_stop(), String.t() | nil) :: any
  def delete_copied(tour_stop, copied_search \\ "%copied") do
    ts = to_string(tour_stop)

    from(ip in InvitedPlayer, where: like(ip.reason, ^copied_search), where: ip.tour_stop == ^ts)
    |> Repo.delete_all()
  end

  def make_unofficial(search \\ "%\\*%") when is_binary(search) do
    from(ip in InvitedPlayer, where: like(ip.reason, ^search))
    |> Repo.update_all(set: [official: false])
  end

  @spec copy_grandmasters(
          Backend.Blizzard.tour_stop(),
          Backen.Blizzard.tour_stop(),
          String.t() | nil,
          String.t() | nil
        ) :: any
  def copy_grandmasters(
        from_ts,
        to_ts,
        excluding \\ MapSet.new([]),
        reason_append \\ " *copied",
        reason_search \\ "%Grandmaster%",
        reason \\ nil
      ) do
    from = to_string(from_ts)
    to = to_string(to_ts)

    Repo.all(
      from ip in InvitedPlayer,
        where: ip.tour_stop == ^from,
        where: like(ip.reason, ^reason_search)
    )
    |> Enum.filter(fn ip ->
      !MapSet.member?(excluding, ip.battletag_full) &&
        !MapSet.member?(excluding, InvitedPlayer.shorten_battletag(ip.battletag_full))
    end)
    |> Enum.uniq_by(&InvitedPlayer.uniq_string/1)
    |> Enum.reduce(Multi.new(), fn gm, multi ->
      # changeset = create_invited_player(%{gm | tour_stop: to_ts, reason: gm.reason <>})
      changeset =
        create_invited_player(%{
          tour_stop: to,
          battletag_full: gm.battletag_full,
          reason: gm.reason <> reason_append,
          official: false,
          upstream_time: gm.upstream_time
        })

      Multi.insert(multi, InvitedPlayer.uniq_string(gm), changeset)
    end)
    |> Repo.transaction()
  end

  @spec get_masters_date_range(:week) :: {Date.t(), Date.t()}
  def get_masters_date_range(:week) do
    # starting from tuesday
    Util.get_range(:week, 2)
  end

  @spec get_masters_date_range(:month) :: {Date.t(), Date.t()}
  def get_masters_date_range(:month) do
    Util.get_range(:month)
  end

  defp get_latest_tuesday() do
    %{year: year, month: month, day: day} = now = Date.utc_today()
    day_of_the_week = :calendar.day_of_the_week(year, month, day)
    days_to_subtract = 0 - rem(day_of_the_week + 5, 7)
    Date.add(now, days_to_subtract)
  end

  def get_qualifiers_for_tour(tour_stop) do
    {start_date, end_date} = guess_qualifier_range(tour_stop)
    BattlefyCommunicator.get_masters_qualifiers(start_date, end_date)
  end

  def guess_qualifier_range(tour_stop) do
    {:ok, seasons} = Blizzard.get_ladder_seasons(tour_stop)
    {min, max} = seasons |> Enum.min_max()
    start_date = Blizzard.get_month_start(min)

    end_date =
      (max + 1)
      |> Blizzard.get_month_start()
      |> Date.add(-1)

    {start_date, end_date}
  end

  @spec get_me_signup_options() :: user_signup_options
  def get_me_signup_options() do
    %{
      user_id: Application.fetch_env!(:backend, :su_user_id),
      token: Application.fetch_env!(:backend, :su_token),
      battletag_full: Application.fetch_env!(:backend, :su_battletag_full),
      battlenet_id: Application.fetch_env!(:backend, :su_battlenet_id),
      discord: Application.fetch_env!(:backend, :su_discord),
      regions: Application.fetch_env!(:backend, :su_regions),
      slug: Application.fetch_env!(:backend, :su_slug)
    }
  end

  def sign_me_up() do
    case Application.fetch_env(:backend, :su_token) do
      {:ok, <<_::binary>>} -> get_me_signup_options() |> signup_player()
      {_, nil} -> {:error, "Missing signup token"}
      {_, reason} -> {:error, reason}
    end
  end

  def add_top_cut(tour_stop, reason, stage_id, opts \\ []) do
    min_wins = opts[:min_wins] || 7
    upstream_time = opts[:upstream_time] || NaiveDateTime.utc_now()

    all =
      list_invited_players(tour_stop)
      |> MapSet.new(fn %{battletag_full: bt} -> InvitedPlayer.shorten_battletag(bt) end)

    Backend.Battlefy.get_stage_standings(stage_id)
    |> Enum.filter(fn s -> s.wins >= min_wins end)
    |> Enum.map(fn s ->
      %{
        tour_stop: to_string(tour_stop),
        battletag_full: String.trim(s.team.name),
        reason: reason,
        type: "invite",
        official: false,
        upstream_time: upstream_time
      }
    end)
    |> Enum.filter(fn %{battletag_full: bt} ->
      !MapSet.member?(all, InvitedPlayer.shorten_battletag(bt))
    end)
    |> insert_all()
  end

  @spec signup_player(user_signup_options) :: any
  def signup_player(options) do
    now = NaiveDateTime.utc_now()
    cutoff = NaiveDateTime.add(now, 14 * 24 * 60 * 60, :second)

    user_tournament_ids =
      BattlefyCommunicator.get_user_tournaments(options.slug)
      |> MapSet.new(fn t -> t.id end)

    missing_qualifier_options =
      BattlefyCommunicator.get_masters_qualifiers(now, cutoff)
      |> Enum.filter(fn q -> Enum.member?(options.regions, q.region) end)
      |> Enum.filter(fn q -> !MapSet.member?(user_tournament_ids, q.id) end)
      |> Enum.map(fn q -> Map.put(options, :tournament_id, q.id) end)

    missing_qualifier_options
    |> Enum.map(&BattlefyCommunicator.signup_for_qualifier/1)
    |> Enum.reduce({:ok, []}, fn result, acc = {_, errors} ->
      case result do
        {:ok, _} -> acc
        {:error, reason} -> {:error, [reason | errors]}
      end
    end)
  end

  @spec create_qualifier_link(Backend.Battlefy.Tournament.t()) :: String.t()
  def create_qualifier_link(t = %{slug: _, id: _, organization: %{slug: _}}) do
    Battlefy.create_tournament_link(t)
  end

  def create_qualifier_link(%{slug: slug, id: id}) do
    create_qualifier_link(slug, id)
  end

  @spec create_qualifier_link(String.t(), String.t()) :: String.t()
  def create_qualifier_link(slug, id) do
    Battlefy.create_tournament_link(slug, id, "hsesports")
  end

  @spec get_gm_money_rankings(Blizzard.gm_season()) :: gm_money_rankings()
  # not implemented yet
  def get_gm_money_rankings({2020, 1}), do: []

  def get_gm_money_rankings(gm_season) do
    Blizzard.get_tour_stops_for_gm!(gm_season)
    # remove the ones happening in the future for which we don't have info
    |> Enum.filter(fn ts ->
      Battlefy.get_tour_stop_id(ts) |> elem(0) == :ok
    end)
    |> Enum.flat_map(fn ts ->
      get_ts_money_rankings(ts)
      |> Enum.map(fn {name, money} -> {name, money, ts} end)
    end)
    |> Enum.group_by(fn {name, _, _} -> get_earnings_group_by(name) end, fn {_, money, tour_stop} ->
      {tour_stop, money}
    end)
    |> Enum.map(fn {name, earnings_list} ->
      {
        name,
        earnings_list |> Enum.map(fn {_, money} -> money end) |> Enum.sum(),
        earnings_list
      }
    end)
    |> Enum.sort_by(fn {_, earnings, _} -> earnings end, :desc)
  end

  def get_earnings_group_by(name) do
    cond do
      name |> String.starts_with?("Jay#") && PlayerNationalityCache.get_actual_battletag(name) ->
        PlayerNationalityCache.get_actual_battletag(name)

      true ->
        name |> InvitedPlayer.shorten_battletag() |> name_hacks()
    end
  end

  def fix_name(name) do
    Regex.replace(~r/^\d\d\d - /, name, "")
    |> name_hacks()
  end

  def name_hacks(name) do
    case name do
      "香菇奾汁" -> "ShroomJuice"
      "撒旦降臨" -> "GivePLZ"
      "LFbleau" -> "LFBleau"
      "ChungLiTaiChihYuan" -> "LzJohn"
      "Liooon" -> "VKLiooon"
      "brimful" -> "Briarthorn"
      "LojomHS" -> "lojom"
      "執念の蒼汁" -> "Aojiru"
      "Syuunen No Aojiru" -> "Aojiru"
      "LPOmegazero" -> "LPOmegaZero"
      "VK.xhx" -> "VKxhx"
      "yuyi" -> "WEYuyi"
      "유워리" -> "6worry"
      n -> n
    end
  end

  @spec get_ts_money_rankings(Blizzard.tour_stop()) :: [{String.t(), number}]
  def get_ts_money_rankings(tour_stop)
      when tour_stop in [:Arlington, :Indonesia, :Jönköping, :"Asia-Pacific", :Montréal, :Madrid] do
    id = Battlefy.get_tour_stop_id!(tour_stop)

    Battlefy.get_tournament(id)
    |> get_2020_earnings(tour_stop)
  end

  @spec get_2020_earnings(Battlefy.Tournament.t(), Blizzard.tour_stop()) :: [{String.t(), number}]
  def get_2020_earnings(%{stages: [swiss, top8]}, tour_stop) do
    top8_standings = Battlefy.get_stage_standings(top8)
    swiss_standings = Battlefy.get_stage_standings(swiss)

    top8_players = top8_standings |> MapSet.new(fn %{team: %{name: name}} -> name end)

    (get_2020_top8_earnings(top8_standings, tour_stop) ++
       get_2020_swiss_earnings(swiss_standings, top8_players))
    |> Enum.sort_by(fn {_, money} -> money end, :desc)
  end

  def get_2020_earnings(%{stages: [swiss]}, _) do
    swiss_standings = Battlefy.get_stage_standings(swiss)

    get_2020_swiss_earnings(swiss_standings, MapSet.new([]))
    |> Enum.sort_by(fn {_, money} -> money end, :desc)
  end

  def get_2020_earnings(_, _) do
    []
  end

  @first_earnings 32_500
  @second_earnings 22_500
  @top4_earnings 15_000
  @top8_earnings 11_000

  @spec get_2020_top8_earnings([Battlefy.Standings.t()], Blizzard.tour_stop()) :: [
          {String.t(), number}
        ]
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def get_2020_top8_earnings(standings, tour_stop) do
    standings
    |> Enum.map(fn %{team: %{name: name}, wins: wins, place: place} ->
      shortened_name = InvitedPlayer.shorten_battletag(name)

      money =
        case {wins, place, tour_stop, shortened_name} do
          # stupid blizzard not updating battlefy till the end
          {_, _, :Arlington, "xBlyzes"} -> @first_earnings
          {3, _, _, _} -> @first_earnings
          {2, _, _, _} -> @second_earnings
          {1, _, _, _} -> @top4_earnings
          {0, _, _, _} -> @top8_earnings
          {nil, 1, _, _} -> @first_earnings
          {nil, 2, _, _} -> @second_earnings
          {nil, 3, _, _} -> @top4_earnings
          {nil, 5, _, _} -> @top8_earnings
          _ -> @top8_earnings
        end

      {name, money}
    end)
  end

  @spec get_2020_swiss_earnings([Battlefy.Standings.t()], MapSet.t()) :: [{String.t(), number}]
  def get_2020_swiss_earnings(standings, top8_players = %MapSet{}) do
    standings
    |> Enum.filter(fn %{team: %{name: name}} -> !MapSet.member?(top8_players, name) end)
    |> Enum.map(fn %{team: %{name: name}, wins: wins} ->
      # top 8 is handled above, don't want to double count
      money =
        case wins do
          # shouldn't happen, but whatever, let's be safe
          8 -> 3500
          7 -> 3500
          6 -> 2250
          5 -> 1000
          _ -> 850
        end

      {name, money}
    end)
  end

  @spec get_packs_earned(integer) :: integer
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def get_packs_earned(position) do
    case position do
      1 -> 20
      2 -> 20
      3 -> 15
      5 -> 10
      9 -> 5
      17 -> 4
      33 -> 3
      65 -> 2
      129 -> 1
      _ -> 0
    end
  end

  def rename_tour_stop(old, new) do
    old_string = to_string(old)
    new_string = to_string(new)

    from(ip in InvitedPlayer, where: ip.tour_stop == ^old_string)
    |> Repo.update_all(set: [tour_stop: new_string])

    from(q in Qualifier, where: q.tour_stop == ^old_string)
    |> Repo.update_all(set: [tour_stop: new_string])
  end

  @spec tour_stops_tournaments() :: [Battlefy.Tournament.t()]
  def tour_stops_tournaments() do
    TourStop.all()
    |> Enum.map(fn ts -> ts.battlefy_id end)
    |> Enum.filter(&Util.id/1)
    |> Enum.map(&Battlefy.get_tournament/1)
  end

  defp to_battelfy_standings({name, place, wins, losses}) do
    %Backend.Battlefy.Standings{
      auto_losses: 0,
      auto_wins: 0,
      losses: losses,
      place: place,
      team: %Backend.Battlefy.Team{name: name},
      wins: wins
    }
  end

  # bucharest, the finals aren't entered in battlefy
  def get_mt_stage_standings(%{id: "5dabfb21c2359802f6cb334e"}) do
    [
      {"Eddie#13420", 1, 3, 0},
      {"kin0531#1125", 2, 2, 1},
      {"totosh#1491", 3, 1, 1},
      {"DeadDraw#11192", 3, 1, 1},
      {"hone#11500", 5, 0, 1},
      {"Orange#13615", 5, 0, 1},
      {"SNBrox#1715", 5, 0, 1},
      {"hunterace#11722", 5, 0, 1}
    ]
    |> Enum.map(&to_battelfy_standings/1)
  end

  # arlington, the finals aren't entered in battelfy
  def get_mt_stage_standings(%{id: "5e36e004c2daa21083f167b5"}) do
    [
      {"xBlyzes#2682", 1, 3, 0},
      {"AyRoK#11677", 2, 2, 1},
      {"Alan870806#1369", 3, 1, 1},
      {"Felkeine#1745", 3, 1, 1},
      {"bloodyface#11770", 5, 0, 1},
      {"TIZS#3227", 5, 0, 1},
      {"totosh#2527", 5, 0, 1},
      {"brimful#1988", 5, 0, 1}
    ]
    |> Enum.map(&to_battelfy_standings/1)
  end

  def get_mt_stage_standings(s) do
    if s |> Battlefy.Stage.bracket_type() == :single_elimination do
      s |> Battlefy.create_standings_from_matches()
    else
      s |> Battlefy.get_stage_standings()
    end
  end

  defp las_vegas_top8_standings() do
    [
      {"dog#1593", 1, 4, 1},
      {"gallon#11212", 2, 3, 1},
      {"tom60229#3684", 3, 2, 1},
      {"posesi#1277", 4, 2, 2},
      {"Hypno#22145", 5, 1, 2},
      {"Kalàxz#2721", 6, 1, 2},
      {"Neirea#2513", 7, 0, 2},
      {"Fenomeno#21327", 8, 0, 2}
    ]
    |> Enum.map(&to_battelfy_standings/1)
  end

  defp seoul_top8_standings() do
    [
      {"168 - Felkeine#1616", 1, 4, 0},
      {"077 - Zhym#11132", 2, 3, 2},
      {"158 - RNGLys#1800", 3, 2, 1},
      {"167 - Magoho#1118", 4, 2, 2},
      {"092 - DeadDraw#11449", 5, 1, 2},
      {"111 - Sooni#11228", 6, 1, 2},
      {"151 - Staz#11286", 7, 0, 2},
      {"063 - Un33D#11378", 8, 0, 2}
    ]
    |> Enum.map(&to_battelfy_standings/1)
  end

  # I merged the group and top4 because I'm lazy, if it ever matters I'll unmerge
  defp get_mt_tournament_stages_standings(%{id: :"Las Vegas", battlefy_id: battlefy_id}) do
    swiss = get_mt_tournament_stages_standings(%{battlefy_id: battlefy_id})
    top8 = {:single_elimination, las_vegas_top8_standings()}
    swiss ++ [top8]
  end

  # I merged the group and top4 because I'm lazy, if it ever matters I'll unmerge
  defp get_mt_tournament_stages_standings(%{id: :Seoul, battlefy_id: battlefy_id}) do
    swiss = get_mt_tournament_stages_standings(%{battlefy_id: battlefy_id})
    top8 = {:single_elimination, seoul_top8_standings()}
    swiss ++ [top8]
  end

  defp get_mt_tournament_stages_standings(%{battlefy_id: battlefy_id}) do
    tournament = Battlefy.get_tournament(battlefy_id)

    tournament.stage_ids
    |> Enum.map(&Battlefy.get_stage/1)
    |> Enum.map(fn s ->
      bracket_type = s |> Battlefy.Stage.bracket_type()
      standings = get_mt_stage_standings(s)
      {bracket_type, standings}
    end)
  end

  @spec masters_tours_stats() :: [[TournamentTeamStats.t()]]
  def masters_tours_stats() do
    TourStop.all()
    |> Enum.filter(fn ts -> ts.battlefy_id end)
    |> Enum.filter(&TourStop.started?/1)
    |> Enum.map(fn ts ->
      # ts.battlefy_id
      # |> Battlefy.get_tournament()
      # |> Battlefy.create_tournament_stats()
      get_mt_tournament_stages_standings(ts)
      |> Backend.TournamentStats.create_tournament_team_stats(ts.id, ts.battlefy_id)
    end)
    |> Enum.filter(fn tts -> Enum.count(tts) > 0 end)
  end

  @spec create_mt_stats_collection([[TournamentTeamStats.t()]]) :: [
          {String.t(), [TournamentTeamStats.t()]}
        ]
  def create_mt_stats_collection(tts) do
    tts
    |> Backend.TournamentStats.create_team_stats_collection(fn n ->
      n
      |> InvitedPlayer.shorten_battletag()
      |> fix_name()
    end)
  end

  def create_player_nationality(
        %Backend.Battlefy.MatchTeam{team: %{name: name, players: [p = %{country_code: cc}]}},
        ts
      )
      when not is_nil(cc) do
    attrs = %{
      mt_battletag_full: name,
      actual_battletag_full: p.battletag,
      twitch: p.twitch,
      nationality: cc,
      tour_stop: to_string(ts)
    }

    %PlayerNationality{}
    |> PlayerNationality.changeset(attrs)
  end

  def create_player_nationality(_, _), do: nil

  def update_player_nationalities(%{battlefy_id: battlefy_id, id: id}) do
    battlefy_id
    |> Battlefy.get_tournament()
    |> case do
      %{stage_ids: [s_id | _]} ->
        matches =
          BattlefyCommunicator.get_matches(s_id, round: 1)
          |> Util.async_map(fn m -> m.id |> BattlefyCommunicator.get_match() end)

        multi =
          matches
          |> Enum.reduce(Multi.new(), fn m, multi ->
            [m.top, m.bottom]
            |> Enum.map(fn t -> create_player_nationality(t, id) end)
            |> Enum.filter(&Util.id/1)
            |> Enum.reduce(multi, fn cs, m ->
              Multi.insert(
                m,
                "player_nationality_#{cs.changes.tour_stop}#{cs.changes.mt_battletag_full}",
                cs
              )
            end)
          end)

        result = multi |> Repo.transaction()
        warmup_player_nationality_cache()
        {:ok, result}

      _ ->
        {:error, "Tournament not ready"}
    end
  end

  def mt_player_nationalities() do
    Repo.all(from(pn in PlayerNationality))
  end

  def warmup_player_nationality_cache() do
    mt_player_nationalities()
    |> PlayerNationalityCache.reinit()
  end

  def same_player?(one, two) do
    one |> InvitedPlayer.shorten_battletag() |> fix_name() ==
      two |> InvitedPlayer.shorten_battletag() |> fix_name()
  end

  def mt_profile_name(short_or_full) do
    with false <- String.contains?(short_or_full, "#"),
         %{actual_battletag_full: bt} when is_binary(bt) <-
           PlayerNationalityCache.get(short_or_full) do
      bt
    else
      _ -> short_or_full
    end
  end

  def invite_2021_01_new_gms(tour_stop) do
    reason = "2021 Hearthstone Grandmaster"

    list = [
      "Leta#21458",
      "Warma#2764",
      "Frenetic#2377",
      "justsaiyan#1493",
      "DreadEye#11302",
      "Impact#1923",
      "Fled#1956",
      "GivePLZ#1207",
      "Hi3#31902",
      "lambyseries#1852"
    ]

    now = NaiveDateTime.utc_now()

    list
    |> Enum.reduce(Multi.new(), fn gm, multi ->
      raw = %{
        tour_stop: tour_stop,
        battletag_full: gm,
        reason: reason,
        official: false,
        upstream_time: now
      }

      changeset = raw |> create_invited_player()
      Multi.insert(multi, InvitedPlayer.uniq_string(raw), changeset)
    end)
    |> Repo.transaction()
  end

  @spec add_top_win_cut([atom()] | atom(), [atom()] | atom()) :: any()
  def add_top_win_cut(targets, sources) when not is_list(targets),
    do: add_top_win_cut([targets], sources)

  def add_top_win_cut(targets, sources) when not is_list(sources),
    do: add_top_win_cut(targets, [sources])

  def add_top_win_cut(targets, sources) when is_list(targets) and is_list(sources) do
    sources
    |> Enum.map(fn ts ->
      tournament =
        ts
        |> TourStop.get_battlefy_id!()
        |> Battlefy.get_tournament()

      {ts, tournament.stage_ids |> Enum.at(0)}
    end)
    |> Enum.each(fn {source, stage_id} ->
      targets
      |> Enum.each(&add_top_cut(&1, "#{source} Top Finisher", stage_id))
    end)
  end

  def get_qualifier(num) do
    with %{qualifiers_period: {start_date, end_date}} <- TourStop.get_current_qualifiers(),
         qualifiers = [_ | _] <- BattlefyCommunicator.get_masters_qualifiers(start_date, end_date) do
      qualifiers
      |> Enum.find(fn %{name: name} ->
        name |> String.contains?("- #{num}") || name |> String.contains?("- ##{num}")
      end)
    else
      _ -> nil
    end
  end
end
