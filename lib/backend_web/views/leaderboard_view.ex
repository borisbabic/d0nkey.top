defmodule BackendWeb.LeaderboardView do
  use BackendWeb, :view
  import Backend.Blizzard
  alias Backend.MastersTour.InvitedPlayer
  @type selectable_season :: {String.t(), integer()}
  @type month_name ::
          :JAN | :FEB | :MAR | :APR | :MAY | :JUN | :JUL | :AUG | :SEP | :OCT | :NOV | :DEC

  @spec create_dropdowns(
          Plug.Conn,
          %{leaderboard_id: String.t(), region: String.t(), season_id: integer} | nil,
          String.t()
        ) :: any()
  def create_dropdowns(conn, nil, ladder_mode),
    do: create_dropdowns(conn, %{leaderboard_id: nil, region: nil, season_id: nil}, ladder_mode)

  def create_dropdowns(
        conn,
        %{
          leaderboard_id: leaderboard_id,
          region: region,
          season_id: season_id
        },
        ladder_mode
      ) do
    [
      create_region_dropdown(conn, region),
      create_leaderboard_dropdown(conn, leaderboard_id),
      create_season_dropdown(conn, season_id),
      create_ladder_mode_dropdown(conn, ladder_mode)
    ]
  end

  def create_region_dropdown(conn, region) do
    options =
      Backend.Blizzard.qualifier_regions_with_name()
      |> Enum.map(fn {r, name} ->
        %{
          display: name,
          selected: to_string(r) == to_string(region),
          link: Routes.leaderboard_path(conn, :index, Map.put(conn.query_params, "region", r))
        }
      end)

    {options, dropdown_title(options, "Region")}
  end

  def create_leaderboard_dropdown(conn, leaderboard_id) do
    options =
      Backend.Blizzard.leaderboards_with_name()
      |> Enum.map(fn {id, name} ->
        %{
          display: name,
          selected: to_string(id) == to_string(leaderboard_id),
          link:
            Routes.leaderboard_path(conn, :index, Map.put(conn.query_params, "leaderboardId", id))
        }
      end)

    {options, dropdown_title(options, "Leaderboard")}
  end

  def create_season_dropdown(conn, season) do
    options =
      create_selectable_seasons(Date.utc_today())
      |> Enum.map(fn {name, s} ->
        %{
          display: name,
          selected: to_string(s) == to_string(season),
          link: Routes.leaderboard_path(conn, :index, Map.put(conn.query_params, "seasonId", s))
        }
      end)

    {options, dropdown_title(options, "Season")}
  end

  def create_ladder_mode_dropdown(conn, ladder_mode) do
    options =
      ["yes", "no"]
      |> Enum.map(fn mode ->
        %{
          display: Recase.to_title(mode),
          selected: mode == ladder_mode,
          link:
            Routes.leaderboard_path(conn, :index, Map.put(conn.query_params, "ladder_mode", mode))
        }
      end)

    {options, "Ladder Mode"}
  end

  def render("index.html", %{leaderboard: nil, conn: conn, ladder_mode: ladder_mode}) do
    render("empty.html", %{dropdowns: create_dropdowns(conn, nil, ladder_mode)})
  end

  def render("index.html", %{
        conn: conn,
        invited: invited_raw,
        highlight: highlight,
        other_ladders: other_ladders,
        leaderboard: leaderboard,
        ladder_mode: ladder_mode
      }) do
    invited = leaderboard |> process_invited(invited_raw) |> add_other_ladders(other_ladders)
    entries = leaderboard |> process_entries(invited)

    render("leaderboard.html", %{
      entries: entries,
      crystal: get_crystal("STD"),
      show_mt_column: show_mt_column?(leaderboard),
      leaderboard_id: leaderboard.leaderboard_id,
      updated_at: leaderboard.upstream_updated_at,
      dropdowns: create_dropdowns(conn, leaderboard, ladder_mode),
      old: old?(leaderboard),
      highlighted: process_highlighted(highlight, entries)
    })
  end

  def show_mt_column?(%{leaderboard_id: "STD", season_id: season_id}),
    do: elem(get_ladder_tour_stop(season_id), 0) == :ok

  def show_mt_column?(_), do: false

  def old(%{upstream_updated_at: updated_at, season_id: season_id}) do
    updated_at && DateTime.diff(DateTime.utc_now(), updated_at) > 3600 &&
      season_id >= get_season_id(Date.utc_today())
  end

  def old?(_), do: false

  def add_other_ladders(invited, other_ladders) do
    other_ladders
    |> Enum.flat_map(fn leaderboard ->
      process_entries(leaderboard, invited)
      |> Enum.filter(fn e -> e.qualifying end)
      |> Enum.with_index(1)
      |> Enum.map(fn {e, pos} -> {e.account_id, {:other_ladder, leaderboard.region, pos}} end)
    end)
    |> Map.new()
    |> Map.merge(invited)
  end

  def get_crystal(leaderboard_id) do
    case leaderboard_id do
      "STD" ->
        "https://d2q63o9r0h0ohi.cloudfront.net/images/leaderboards/crystal_standard-add3c953a625a04c8545699c65c338786606c56e770182c236c7ec5229bf5f1e78631e57bcdda6eee820f3a13e57e97fe22f0e39b5777c7e41b75ce28f3bd8c7.png"

      "BG" ->
        "https://d2q63o9r0h0ohi.cloudfront.net/images/leaderboards/crystal_battlegrounds-5cd82d919afcfc5de20e0857cfce3e19ba9bd47d8f02ab977d3fa3a17b9dc7c972a18e0f55eb970ff0639aa69045b3aacb3cc1125d17a9550bd5ed7167a51aea.png"

      "WLD" ->
        "https://d2q63o9r0h0ohi.cloudfront.net/images/leaderboards/crystal_wild-f9075a1fe0a5953b314fab5ca15f7cc83db86764786f590b8d64fb87603f797adbfd75ffd6160d89bf53ae08eb50d032a3d9d6885c0e03b0fcd6f22265aa6a0f.png"

      _ ->
        "https://d2q63o9r0h0ohi.cloudfront.net/images/leaderboards/crystal_standard-add3c953a625a04c8545699c65c338786606c56e770182c236c7ec5229bf5f1e78631e57bcdda6eee820f3a13e57e97fe22f0e39b5777c7e41b75ce28f3bd8c7.png"
    end
  end

  @doc """
    Creates the list of months that will be shown in the dropdown

    Unless it's the first or last of a month then it shows the current month, then the two previous
    If it's the first of a month it put's the previous month in first place
    If it's the last of the month it put's the next month in second place
    (see examples)
    ## Example
    iex> BackendWeb.LeaderboardView.create_selectable_seasons(~D[2020-01-01])
    [{:January, 75}, {:December, 74}, {:November, 73}, {:October, 72}, {:September, 71}, {:August, 70}]
    iex> BackendWeb.LeaderboardView.create_selectable_seasons(~D[2019-12-31])
    [{:January, 75}, {:December, 74}, {:November, 73}, {:October, 72}, {:September, 71}, {:August, 70}]
  """
  @spec create_selectable_seasons(Calendar.date()) :: [selectable_season]
  def create_selectable_seasons(today) do
    tomorrow = Date.add(today, 1)
    tomorrow_id = get_season_id(tomorrow)
    # if it's the first day of jan or last day of dec we want to show [dec, jan, nov]
    [0, -1, -2, -3, -4, -5]
    |> Enum.map(fn month_diff ->
      month_num = Util.normalize_month(month_diff + tomorrow.month)
      {get_month_name(month_num), tomorrow_id + month_diff}
    end)
  end

  @doc """
  Gets three letter month name for a month number

  ## Example
    iex> BackendWeb.LeaderboardView.get_month_name(12)
    :December
    iex> BackendWeb.LeaderboardView.get_month_name(1)
    :January
  """
  @spec get_month_name(integer) :: month_name
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def get_month_name(month) do
    case month do
      1 -> :January
      2 -> :February
      3 -> :March
      4 -> :April
      5 -> :May
      6 -> :June
      7 -> :July
      8 -> :August
      9 -> :September
      10 -> :October
      11 -> :November
      12 -> :December
      x -> to_string(x)
    end
  end

  def process_invited(nil, invited_raw), do: process_invited(invited_raw, NaiveDateTime.utc_now())

  def process_invited(%{upstream_updated_at: updated_at}, invited_raw),
    do: process_invited(invited_raw, updated_at)

  def process_invited(invited_raw, updated_at) do
    not_invited_afterwards = fn ip ->
      ip.upstream_time
      |> NaiveDateTime.compare(updated_at)
      |> Kernel.==(:lt)
    end

    case updated_at do
      nil -> invited_raw
      _ -> Enum.filter(invited_raw, not_invited_afterwards)
    end
    |> InvitedPlayer.prioritize(&InvitedPlayer.shorten_battletag/1)
    |> Map.new(fn ip ->
      {InvitedPlayer.shorten_battletag(ip.battletag_full), InvitedPlayer.source(ip)}
    end)
  end

  def process_highlighted(highlighted_raw, entry) do
    is_highlighted = fn %{battletag: battletag} ->
      MapSet.member?(highlighted_raw, to_string(battletag))
    end

    if highlighted_raw && Enum.any?(entry, is_highlighted) do
      Enum.filter(entry, is_highlighted)
    else
      nil
    end
  end

  def process_entries(nil, _), do: []

  def process_entries(%{entries: entries}, invited) do
    Enum.map_reduce(entries, 0, fn le = %{account_id: account_id}, acc ->
      qualified = Map.get(invited, to_string(account_id))
      qualifying = !qualified && acc < 16

      {Map.put_new(le, :qualified, qualified)
       |> Map.put_new(:qualifying, qualifying),
       if qualified do
         acc
       else
         acc + 1
       end}
    end)
    |> elem(0)
  end
end
