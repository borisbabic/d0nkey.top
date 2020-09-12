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
  alias Backend.MastersTour.TourStop
  alias Backend.Infrastructure.BattlefyCommunicator
  alias Backend.Infrastructure.PlayerStatsCache
  alias Backend.Blizzard
  alias Backend.Battlefy

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
    |> Blizzard.get_year_for_tour_stop()
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
        reason_search \\ "%Grandmaster%"
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
  def create_qualifier_link(t = %{slug: slug, id: id, organization: %{slug: org_slug}}) do
    Battlefy.create_tournament_link(t)
  end

  @spec create_qualifier_link(Backend.Battlefy.Tournament.t()) :: String.t()
  def create_qualifier_link(%{slug: slug, id: id}) do
    create_qualifier_link(slug, id)
  end

  @spec create_qualifier_link(String.t(), String.t()) :: String.t()
  def create_qualifier_link(slug, id) do
    Battlefy.create_tournament_link(slug, id, "hsesports")
  end

  @spec get_gm_money_rankings(Blizzard.gm_season()) :: gm_money_rankings()
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
    |> Enum.group_by(fn {name, _, _} -> name_hacks(name) end, fn {_, money, tour_stop} ->
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

  def name_hacks(name) do
    case name do
      "Liooon" -> "VKLiooon"
      "brimful" -> "Briarthorn"
      "LojomHS" -> "lojom"
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

  @spec get_2020_earnings(Battlefy.Tournament.t(), Blizzard.tour_stop()) :: [{String.t(), number}]
  def get_2020_earnings(%{stages: [swiss]}, _) do
    swiss_standings = Battlefy.get_stage_standings(swiss)

    get_2020_swiss_earnings(swiss_standings, MapSet.new([]))
    |> Enum.sort_by(fn {_, money} -> money end, :desc)
  end

  def get_2020_earnings(_, _) do
    []
  end

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
          {_, _, :Arlington, "xBlyzes"} -> 32_500
          {3, _, _, _} -> 32_500
          {2, _, _, _} -> 22_500
          {1, _, _, _} -> 15_000
          {0, _, _, _} -> 11_000
          {nil, 1, _, _} -> 32_500
          {nil, 2, _, _} -> 22_500
          {nil, 3, _, _} -> 15_000
          {nil, 5, _, _} -> 11_000
          _ -> 11_000
        end

      {shortened_name, money}
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

      {InvitedPlayer.shorten_battletag(name), money}
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
end
