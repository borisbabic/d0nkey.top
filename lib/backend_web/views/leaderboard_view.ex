defmodule BackendWeb.LeaderboardView do
  use BackendWeb, :view
  alias Backend.MastersTour.InvitedPlayer

  def render("index.html", %{
        invited: invited_raw,
        entry: entry_raw,
        conn: conn,
        region: region,
        leaderboard_id: leaderboard_id,
        updated_at: updated_at,
        highlight: highlighted_raw
      }) do
    updated_at_string = process_updated_at(updated_at)
    invited = process_invited(invited_raw, updated_at)
    entry = process_entry(entry_raw, invited)
    highlighted = process_highlighted(highlighted_raw, entry)
    season_id = conn.query_params["seasonId"]
    {selectable_seasons, season_name, is_latest_season} = handle_seasons(season_id)
    old = updated_at && DateTime.diff(DateTime.utc_now(), updated_at) > 3600 && is_latest_season

    render("index.html", %{
      conn: conn,
      entry: entry,
      region: region,
      leaderboard_id: leaderboard_id,
      old: old,
      updated_at: updated_at_string,
      highlighted: highlighted,
      season_id: season_id,
      selectable_seasons: selectable_seasons,
      season_name: season_name,
      crystal: get_crystal(leaderboard_id)
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

  def handle_seasons(season_id) do
    # todo generate these from the current date
    selectable_seasons = [{"JAN", 75}, {"DEC", 74}, {"NOV", 73}]
    latest = {_, latest_season_id} = Enum.at(selectable_seasons, 0)

    season_selector = fn season_tuple ->
      to_string(elem(season_tuple, 1)) == to_string(season_id)
    end

    {season_name, curr_season_id} = Enum.find(selectable_seasons, latest, season_selector)

    {selectable_seasons, season_name, curr_season_id == latest_season_id}
  end

  def process_updated_at(_ = nil) do
    nil
  end

  def process_updated_at(updated_at) do
    updated_at
    |> DateTime.to_iso8601()
    |> String.splitter(".")
    |> Enum.at(0)
    |> String.replace("T", " ")
  end

  def process_invited(invited_raw, updated_at) do
    not_invited_afterwards = fn ip ->
      ip.upstream_time
      |> NaiveDateTime.compare(updated_at)
      |> Kernel.==(:lt)
    end

    invited_raw
    |> Enum.filter(not_invited_afterwards)
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
