defmodule BackendWeb.LeaderboardView do
  use BackendWeb, :view

  def render("index.html", %{
        invited: invited_raw,
        entry: entry_raw,
        conn: conn,
        region: region,
        leaderboard_id: leaderboard_id,
        updated_at: updated_at,
        highlight: highlighted_raw
      }) do
    invited = process_invited(invited_raw)
    entry = process_entry(entry_raw, invited)
    highlighted = process_highlighted(highlighted_raw, entry)
    old = updated_at && DateTime.diff(DateTime.utc_now(), updated_at) > 3600
    updated_at_string = process_updated_at(updated_at)

    render("index.html", %{
      conn: conn,
      entry: entry,
      region: region,
      leaderboard_id: leaderboard_id,
      old: old,
      updated_at: updated_at_string,
      highlighted: highlighted
    })
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

  def process_invited(invited_raw) do
    MapSet.new(
      invited_raw,
      fn ip ->
        String.splitter(ip.battletag_full, "#")
        |> Enum.at(0)
        |> to_string()
      end
    )
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
