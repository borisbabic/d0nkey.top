defmodule BackendWeb.LeaderboardView do
  use BackendWeb, :view
  import Backend.Blizzard
  alias Backend.MastersTour.InvitedPlayer
  @type selectable_season :: {String.t(), integer()}
  @type month_name ::
          :JAN | :FEB | :MAR | :APR | :MAY | :JUN | :JUL | :AUG | :SEP | :OCT | :NOV | :DEC

  def render("index.html", %{
        invited: invited_raw,
        entry: entry_raw,
        conn: conn,
        region: region,
        leaderboard_id: leaderboard_id,
        updated_at: updated_at,
        highlight: highlighted_raw,
        season_id: season_id
      }) do
    invited = process_invited(invited_raw, updated_at)
    entry = process_entry(entry_raw, invited)
    highlighted = process_highlighted(highlighted_raw, entry)
    today = Date.utc_today()
    selectable_seasons = create_selectable_seasons(today)

    old =
      updated_at && DateTime.diff(DateTime.utc_now(), updated_at) > 3600 &&
        season_id >= get_season_id(today)

    show_mt_column =
      to_string(leaderboard_id) == "STD" && elem(get_ladder_tour_stop(season_id), 0) == :ok

    render("index.html", %{
      conn: conn,
      entry: entry,
      region: region,
      leaderboard_id: leaderboard_id,
      old: old,
      updated_at: updated_at,
      highlighted: highlighted,
      season_id: season_id,
      selectable_seasons: selectable_seasons,
      season_name: get_month_name(get_month_start(season_id).month),
      crystal: get_crystal(leaderboard_id),
      show_mt_column: show_mt_column
    })
  end

  def get_crystal(leaderboard_id) do
    case leaderboard_id do
      "STD" ->
        "https://d2q63o9r0h0ohi.cloudfront.net/images/leaderboards/crystal_standard-add3c953a625a04c8545699c65c338786606c56e770182c236c7ec5229bf5f1e78631e57bcdda6eee820f3a13e57e97fe22f0e39b5777c7e41b75ce28f3bd8c7.png"

      "BG" ->
        "https://d2q63o9r0h0ohi.cloudfront.net/images/leaderboards/crystal_battlegrounds-5cd82d919afcfc5de20e0857cfce3e19ba9bd47d8f02ab977d3fa3a17b9dc7c972a18e0f55eb970ff0639aa69045b3aacb3cc1125d17a9550bd5ed7167a51aea.png"

      "WLD" ->
        "https://d2q63o9r0h0ohi.cloudfront.net/images/leaderboards/crystal_wild-f9075a1fe0a5953b314fab5ca15f7cc83db86764786f590b8d64fb87603f797adbfd75ffd6160d89bf53ae08eb50d032a3d9d6885c0e03b0fcd6f22265aa6a0f.png"
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
    [DEC: 74, JAN: 75, NOV: 73]
    iex> BackendWeb.LeaderboardView.create_selectable_seasons(~D[2019-12-31])
    [DEC: 74, JAN: 75, NOV: 73]
    iex> BackendWeb.LeaderboardView.create_selectable_seasons(~D[2019-12-12])
    [DEC: 74, NOV: 73, OCT: 72]
  """
  @spec create_selectable_seasons(Calendar.date()) :: [selectable_season]
  def create_selectable_seasons(today) do
    tomorrow = Date.add(today, 1)
    tomorrow_id = get_season_id(tomorrow)
    # if it's the first day of jan or last day of dec we want to show [dec, jan, nov]
    if tomorrow.day in [1, 2] do
      # month difference compared to tomorrow
      [-1, 0, -2]
    else
      [0, -1, -2]
    end
    |> Enum.map(fn month_diff ->
      month_num = Util.normalize_month(month_diff + tomorrow.month)
      {get_month_name(month_num), tomorrow_id + month_diff}
    end)
  end

  @doc """
  Gets three letter month name for a month number

  ## Example
    iex> BackendWeb.LeaderboardView.get_month_name(12)
    :DEC
    iex> BackendWeb.LeaderboardView.get_month_name(1)
    :JAN
  """
  @spec get_month_name(integer) :: month_name
  # complexity is too high
  # credo:disable-for-this-file
  def get_month_name(month) do
    case month do
      1 -> :JAN
      2 -> :FEB
      3 -> :MAR
      4 -> :APR
      5 -> :MAY
      6 -> :JUN
      7 -> :JUL
      8 -> :AUG
      9 -> :SEP
      10 -> :OCT
      11 -> :NOV
      12 -> :DEC
      x -> to_string(x)
    end
  end

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
    |> MapSet.new(fn ip -> InvitedPlayer.shorten_battletag(ip.battletag_full) end)
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

  def process_entry(entry_raw, invited) do
    Enum.map_reduce(entry_raw, 0, fn le = %{battletag: battletag}, acc ->
      qualified = MapSet.member?(invited, to_string(battletag))
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
