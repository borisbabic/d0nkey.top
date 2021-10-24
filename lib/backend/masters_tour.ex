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
  alias Backend.Battlefy.Stage
  alias Backend.Battlefy.Standings
  alias Backend.Grandmasters.PromotionCalculator
  alias Backend.TournamentStats.TournamentTeamStats
  alias Backend.Infrastructure.ApiCache

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
  import Torch.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  @pagination [page_size: 15]
  @pagination_distance 5

  def invited_player_changeset(attrs \\ %{}) do
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

  def list_officially_invited_players(tour_stop) do
    list_invited_players(tour_stop) |> Enum.filter(& &1.official)
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
    [2020, 2021]
    |> Enum.flat_map(fn y -> [y | Backend.Blizzard.get_tour_stops_for_year(y)] end)
    |> List.insert_at(0, :all)
    |> Enum.each(&Backend.MastersTour.get_player_stats/1)
  end

  def create_and_cache_stats(qualifiers, period) do
    stats = PlayerStats.create_collection(qualifiers)
    ret = {stats, Enum.count(qualifiers)}
    PlayerStatsCache.set(period, ret)
    ret
  end

  def get_player_stats(:all) do
    case PlayerStatsCache.get(:all) do
      nil ->
        list_qualifiers()
        |> create_and_cache_stats(:all)

      s ->
        s
    end
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

  @spec list_qualifiers() :: [Qualifier]
  def list_qualifiers() do
    query =
      from q in Qualifier,
        select: q,
        order_by: [desc: q.start_time]

    query |> Repo.all()
  end

  @spec list_qualifiers_for_player(Blizzard.battletag()) :: [Qualifier]
  def list_qualifiers_for_player(battletag_full) do
    search = "%#{battletag_full}%"

    query =
      from q in Qualifier,
        select: q,
        where: like(fragment("to_jsonb(?)::text", q.standings), ^search),
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

    PlayerStatsCache.delete(:all)
  end

  def qualifiers_update() do
    TourStop.get_current_qualifiers(:id)
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
      cs = ip |> invited_player_changeset()
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
      changeset = invited_player_changeset(np)
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
      # changeset = invited_player_changeset(%{gm | tour_stop: to_ts, reason: gm.reason <>})
      changeset =
        invited_player_changeset(%{
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
    {start_date, end_date} =
      TourStop.get(tour_stop, :qualifiers_period) || guess_qualifier_range(tour_stop)

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

  def get_gm_money_rankings(gm_season, system) do
    PromotionCalculator.for_season(gm_season, system)
    |> PromotionCalculator.convert_to_legacy()
  end

  def fix_name(name) do
    Regex.replace(~r/^\d\d\d - /, name, "")
    |> name_hacks()
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def name_hacks(name) do
    new = name
    # Chinese players had it added. It's not valid in a battletag
    |> String.replace(".", "")
    |> case do
      "香菇奾汁" -> "ShroomJuice"
      "撒旦降臨" -> "GivePLZ"
      "LFbleau" -> "LFBleau"
      "ChungLiTaiChihYuan" -> "LzJohn"
      "Liooon" -> "VKLiooon"
      "brimful" -> "Briarthorn"
      "SphnxManatee" -> "Briarthorn"
      "LojomHS" -> "lojom"
      "執念の蒼汁" -> "Aojiru"
      "Syuunen No Aojiru" -> "Aojiru"
      "VK.xhx" -> "VKxhx"
      "yuyi" -> "WEYuyi"
      "유워리" -> "6worry"
      "bloodyface" -> "lunaloveee"
      "AjjXiGuan" -> "BilibiliXG"
      "Backup2" -> "GamerRvg"
      # <zflow> https://docs.google.com/document/d/1AhHUQWVJeBjPLHveFtJ2fwfVikZAiNsDXRO3CQiXaKQ/edit
      "게임이기기봇" -> "che0nsu"
      "Che0nsu" -> "che0nsu"

      "무에서유창조" -> "Crefno"
      "mueseoyuchangjo" -> "Crefno"
      "현명한로나" -> "LoNa"

      "슬퍼하지마노노노" -> "SuperKimchi"
      "ZizonZzang" -> "SuperKimchi"
      "wellmadekimchi" -> "SuperKimchi"

      "잔악무도유관우" -> "kwanwoo"
      "신명수" -> "soo"
      "독도는한국" -> "DokdonuenKR"
      "달라라면" -> "Dallara"

      "호랑이들어와요" -> "Hodeulyo"
      "ilikeryan" -> "Hodeulyo"
      "현명한라이언" -> "Hodeulyo"

      "지기" -> "keeper"

      "현명한라이언" -> "ilikeryan"
      "막강한올빼미" -> "Makganghanol"
      "이스티" -> "LuiSti"
      "ESti" -> "LuiSti"
      "최석중" -> "ChoiSeokJoon"
      # </zflow>
      #
      # Battlefy
      "wiwi" -> "麻煩"
      # dm from youth
      "虎牙丶季岁" -> "Youth"

      "LPOmegazero" -> "OmegaZero"
      "LPOmegaZero" -> "OmegaZero"

      "RNGKylinS" -> "RNGKylin"
      "LFyueying" -> "LFYueying"
      "水墨烬千年" -> "ShuiMoo"
      "TGcaimiao" -> "Caimiao"
      "LGDCaimiao" -> "Caimiao"

      "不忘初心丶天命" -> "Tianming"
      "VKTianming" -> "Tianming"

      "于是乎" -> "WolfWarrior2"
      "WolfWarriors2" -> "WolfWarrior2"
      "不忘初心丶石头记" -> "WEStone"
      "虎牙丶元素" -> "WEYuansu"
      "儒雅随和丨小菜泫" -> "RyshHyunGod"
      "不忘初心丶麻辣烫" -> "DarrenF"
      "不要自闭" -> "yuki"
      "不忘初心丶小惕" -> "XiaoT"
      "斗鱼丶古明地觉" -> "Satori"
      "虎牙丶特兰克斯" -> "LPTrunks"

      "msbc" -> "VKmsbc"
      "WEBaKu" -> "VKmsbc" #https://twitter.com/1ArchangelCN/status/1452317525220470787

      "destiny" -> "LPdestiny"
      "Lpdestiny" -> "LPdestiny"

      "LPXHope" -> "LPXhope"

      "TNCAnswer" -> "VKAnswer" # I Assume

      "LFBleau3" -> "LFBleau" # I Assume

      "BLGMelody" -> "Melody"
      "和同学们分享思维" -> "Melody" # through battlefy user id
      "马皇" -> "Melody" # through battlefy user id

      "我觉得你有点严格" -> "paopao" # through battlefy user id
      "元气满满的泡泡" -> "paopao" # through battlefy user id

      ### <AUTOMATED through battlefy id>
      "紅蓮聖天八極式" -> "hirosueryouko"

      "広末涼子" -> "hirosueryouko"

      "素芬儿别走" -> "M1racle"

      "양봉꾼" -> "Beekeeper"

      "Backup5" -> "MinusFace"

      "StarPatron" -> "WedgmBql"

      "周郎神的粉丝" -> "LFBleau"

      "DikiyZver" -> "WildAnimalHS"

      "雷霸霸" -> "LBB"

      "虎牙丶白给雷霸霸" -> "LBB"

      "WGLBB" -> "LBB"

      "illusion" -> "虎牙丶幻觉"

      "Backup6" -> "虎牙丶幻觉"

      "あなる王子" -> "Theprince"

      "라이언" -> "Hodeulyo"

      "jerry" -> "Jerry"

      "BloodyfaceCN" -> "XiaoT"

      # "一生所爱丶小梦佳" -> "Xiaomengjia"

      # "ifbdz" -> "Xiaomengjia"

      # "Buduzhou" -> "Xiaomengjia"

      # "KT8298" -> "XilingHangHS"

      "Backup3" -> "XilingHangHS"

      # "西陵珩" -> "XilingHangHS"

      # "youngjoon" -> "hemlock"

      # "TIAhuanxiong" -> "VKxhx"

      # "mighty" -> "Makganghanol"

      "Backup4" -> "Tomas"

      "약강" -> "SsamMyway"

      "Ssam-myway" -> "SsamMyway"

      "山下智久" -> "G9Malygos"

      "MiracleRogue" -> "M1racle"

      "則龍之王" -> "jaylong"

      "진원치킨" -> "Woobin"

      "てっぺ" -> "tepepe"

      "WEChengxin" -> "SNCx"

      "ПашаТехник" -> "MCTech"

      "애대박" -> "Aedaebak"

      "JrsJokerRing" -> "JokerRing"

      "자바" -> "Sidnell"

      "JaeWon" -> "재언"

      "Alex" -> "AlexJP"

      "AlexHS" -> "AlexJP"

      "あれっくす" -> "AlexJP"

      "Backup1" -> "NoGlocko"

      "DarrenF" -> "DarranF"

      "哈利" -> "Harry"

      "IziBot" -> "Danneskjöld"

      "튀긴새우" -> "zriag"

      "BadBoy" -> "Badboy"

      "샹하이" -> "Shanghigh"

      "中壢邰智源" -> "LzJohn"

      "マイマイ" -> "maimai"

      "상추" -> "Sangchu"

      "プラス" -> "plus"

      "AjjStone" -> "WEStone"

      "gallon" -> "Gallon"

      "anartica" -> "아나티카"

      "로좀" -> "lojom"

      "Moriaty" -> "Moriarty"

      # "Amazing" -> "UchihaMadara"

      "承泰不要" -> "Bloodtrail"

      "HérosFunky" -> "Thedemon"

      "SNRugal" -> "为何介么叼"

      "MANHATTAN" -> "Kranich"

      "不忘初心丶小王" -> "LGDXiaoWang"

      # "Intro" -> "jwrobel"

      "WEYoulove" -> "WELuckyLove"

      "WEYouLove" -> "WELuckyLove"

      "タコ3" -> "Octopus3"

      "佳静" -> "Cyberostrich"

      "cyberostrich" -> "Cyberostrich"

      "destinyfan" -> "VKDiana"

      "sakura" -> "Sakura"

      "聖水洋洋" -> "holywater"

      "Lucasdmnasc" -> "lucasdmnasc"

      "살아있는양심" -> "sheepheart"

      # "MAWANG" -> "LGDMurphy"

      "WedgmMurphy" -> "LGDMurphy"

      "FiveKSMeng" -> "Mengmengda"

      "神秘的萌萌哒" -> "Mengmengda"

      "HyunMini" -> "현명한현민이"

      "にん" -> "Nin"

      "JrsConley" -> "JrsRandolph"

      "jrsConley" -> "JrsRandolph"

      "龜毛老頭" -> "GMLT"

      "자유조퇴권" -> "Jajo"

      "cagnetta99" -> "lattosio"

      # "cdkFoot" -> "FiveKSJioJio"

      "조치" -> "Zochi"

      "Dragonmaster" -> "PrestX"

      "虎牙深海羽翼" -> "KZGYuYi"

      "WEYuyi" -> "KZGYuYi"

      "WEYuYi" -> "KZGYuYi"

      # "WedgmBql" -> "KZGXiaobai"

      # "Baiqinli" -> "KZGXiaobai"

      "Alan870806" -> "AlanC86"

      "WedgmXmg" -> "KZGXmg"

      ### </AUTOMATED>
      n -> n
    end
    if new == name do
      new
    else
      name_hacks(new)
    end
  end

  defp use_cached_value?(cached, ts = %TourStop{}),
    do: !TourStop.current?(ts) && (cached || !TourStop.started?(ts))

  defp mt_tournament_cache_key(%{id: id}), do: "mt_tournament_#{id}"

  def get_mt_tournament(ts) when is_atom(ts) or is_binary(ts),
    do: ts |> TourStop.get() |> get_mt_tournament()

  def get_mt_tournament(ts = %TourStop{}) do
    cached = get_mt_tournament(ts, :cache)

    if use_cached_value?(cached, ts) do
      cached
    else
      val = get_mt_tournament(ts, :fresh)

      if val do
        ts
        |> mt_tournament_cache_key()
        |> ApiCache.set(val)
      end

      val
    end
  end

  def get_mt_tournament(ts, :cache), do: ts |> mt_tournament_cache_key() |> ApiCache.get()

  def get_mt_tournament(%{battlefy_id: battlefy_id}, :fresh),
    do: Battlefy.get_tournament(battlefy_id)

  defp mt_stage_cache_key(%{id: id}), do: mt_stage_cache_key(id)
  defp mt_stage_cache_key(stage_id), do: "mt_stage_#{stage_id}"

  def get_mt_stage(stage_id, ts = %TourStop{}) do
    cached = get_mt_stage(stage_id, :cache)

    if use_cached_value?(cached, ts) do
      cached
    else
      val = get_mt_stage(stage_id, :fresh)

      if val do
        stage_id
        |> mt_stage_cache_key()
        |> ApiCache.set(val)
      end

      val
    end
  end

  def get_mt_stage(stage_id, :cache), do: stage_id |> mt_stage_cache_key() |> ApiCache.get()
  def get_mt_stage(stage_id, :fresh), do: Battlefy.get_stage(stage_id)

  def get_mt_stage(stage_id, ts_id) when is_atom(ts_id) do
    ts = ts_id |> TourStop.get()
    get_mt_stage(stage_id, ts)
  end

  defp mt_stage_standings_cache_key(%{id: id}), do: "mt_stage_standings_#{id}"

  @spec get_mt_stage_standings(Stage.t(), TourStop.t() | Blizzard.tour_stop() | :cache | :fresh) ::
          [Standings.t()]
  def get_mt_stage_standings(stage, ts = %TourStop{}) do
    cached = get_mt_stage_standings(stage, :cache)

    if use_cached_value?(cached, ts) do
      cached || []
    else
      val = get_mt_stage_standings(stage, :fresh)

      if val do
        stage
        |> mt_stage_standings_cache_key()
        |> ApiCache.set(val)
      end

      val
    end
  end

  def get_mt_stage_standings(stage, :cache),
    do: stage |> mt_stage_standings_cache_key() |> ApiCache.get()

  def get_mt_stage_standings(stage, :fresh), do: get_mt_stage_standings(stage)

  def get_mt_stage_standings(stage, ts_id) do
    ts = ts_id |> TourStop.get()
    get_mt_stage_standings(stage, ts)
  end

  @spec get_mt_stage_standings(Stage.t()) :: [Standings.t()]
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

  def get_mt_stage_standings(s = %Stage{}) do
    if s |> Battlefy.Stage.bracket_type() == :single_elimination do
      s |> Battlefy.create_standings_from_matches()
    else
      s |> Battlefy.get_stage_standings()
    end
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
  defp add_missing_top_cut(swiss, %{id: :"Las Vegas"}) do
    top8 = {:single_elimination, las_vegas_top8_standings()}
    swiss ++ [top8]
  end

  # I merged the group and top4 because I'm lazy, if it ever matters I'll unmerge
  defp add_missing_top_cut(swiss, %{id: :Seoul}) do
    top8 = {:single_elimination, seoul_top8_standings()}
    swiss ++ [top8]
  end

  defp add_missing_top_cut(stages, _), do: stages

  defp get_mt_tournament_stages_standings(ts = %TourStop{}) do
    tournament = get_mt_tournament(ts)

    tournament.stage_ids
    |> Enum.map(&get_mt_stage(&1, ts))
    |> Enum.map(fn s ->
      bracket_type = s |> Battlefy.Stage.bracket_type()
      standings = get_mt_stage_standings(s, ts)
      {bracket_type, standings}
    end)
    |> add_missing_top_cut(ts)
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
          |> Util.async_map(fn m -> m.id |> BattlefyCommunicator.get_match!() end)

        multi =
          matches
          |> Enum.reduce(Multi.new(), fn m, multi ->
            [m.top, m.bottom]
            |> Enum.map(fn t -> create_player_nationality(t, id) end)
            |> Enum.filter(&Util.id/1)
            # credo:disable-for-next-line Credo.Check.Refactor.Nesting
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

  def mt_player_nationalities(tour_stop) do
    string_ts = to_string(tour_stop)

    query =
      from pn in PlayerNationality,
        where: pn.tour_stop == ^string_ts,
        select: pn

    Repo.all(query)
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

      changeset = raw |> invited_player_changeset()
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

  @doc """
  Paginate the list of invited_player using filtrex
  filters.

  ## Examples

      iex> list_invited_player(%{})
      %{invited_player: [%InvitedPlayer{}], ...}
  """
  @spec paginate_invited_player(map) :: {:ok, map} | {:error, any}
  def paginate_invited_player(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:invited_player), params["invited_player"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_invited_player(filter, params) do
      {:ok,
       %{
         invited_player: page.entries,
         page_number: page.page_number,
         page_size: page.page_size,
         total_pages: page.total_pages,
         total_entries: page.total_entries,
         distance: @pagination_distance,
         sort_field: sort_field,
         sort_direction: sort_direction
       }}
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_invited_player(filter, params) do
    InvitedPlayer
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config(:invited_player) do
    defconfig do
      text(:battletag_full)
      text(:tour_stop)
      text(:type)
      text(:reason)
      datetime(:upstream_time)
      text(:tournament_slug)
      text(:tournament_id)
    end
  end

  def get_invited_player!(id), do: Repo.get!(InvitedPlayer, id)

  @doc """
  Updates a invited_player.

  ## Examples

      iex> update_invited_player(invited_player, %{field: new_value})
      {:ok, %InvitedPlayer{}}

      iex> update_invited_player(invited_player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invited_player(%InvitedPlayer{} = invited_player, attrs) do
    invited_player
    |> InvitedPlayer.changeset(attrs)
    |> Repo.update()
  end

  def change_invited_player(%InvitedPlayer{} = ip, attrs \\ %{}),
    do: InvitedPlayer.changeset(ip, attrs)

  def create_invited_player(attrs \\ %{}),
    do: attrs |> invited_player_changeset() |> Repo.insert()

  def delete_invited_player(%InvitedPlayer{} = ip), do: Repo.delete(ip)
end
