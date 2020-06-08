defmodule Backend.MastersTour do
  @moduledoc """
    The MastersTour context.
  """
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.Infrastructure.BattlefyCommunicator
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
    start_time = get_latest_tuesday()
    end_time = Date.add(start_time, 7)
    {start_time, end_time}
  end

  @spec get_masters_date_range(:month) :: {Date.t(), Date.t()}
  def get_masters_date_range(:month) do
    today = %{year: year, month: month, day: day} = Date.utc_today()

    start_of_month =
      case Date.new(year, month, 1) do
        {:ok, date} -> date
        # this should never happen
        {:error, reason} -> throw(reason)
      end

    end_of_month = Date.add(start_of_month, Date.days_in_month(today) - day)
    {start_of_month, end_of_month}
  end

  defp get_latest_tuesday() do
    %{year: year, month: month, day: day} = now = Date.utc_today()
    day_of_the_week = :calendar.day_of_the_week(year, month, day)
    days_to_subtract = 0 - rem(day_of_the_week + 5, 7)
    Date.add(now, days_to_subtract)
  end

  def get_qualifiers_for_tour(tour_stop) do
    {start_date, end_date} = guess_qualifier_range(tour_stop)
    Backend.Infrastructure.BattlefyCommunicator.get_masters_qualifiers(start_date, end_date)
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
  def create_qualifier_link(%{slug: slug, id: id}) do
    create_qualifier_link(slug, id)
  end

  @spec create_qualifier_link(String.t(), String.t()) :: String.t()
  def create_qualifier_link(slug, id) do
    "https://battlefy.com/hsesports/#{slug}/#{id}/info"
  end

  @spec get_gm_money_rankings(Blizzard.gm_season()) :: gm_money_rankings
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
    |> Enum.group_by(fn {name, _, _} -> name end, fn {_, money, tour_stop} ->
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

  @spec get_ts_money_rankings(Blizzard.tour_stop()) :: [{String.t(), number}]
  def get_ts_money_rankings(tour_stop)
      when tour_stop in [:Arlington, :Indonesia, :Jönköping, :"Asia-Pacific", :Montreal, :Madrid] do
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

  @spec get_2020_top8_earnings([Battlefy.Standings.t()], MapSet.t()) :: [{String.t(), number}]
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
end
