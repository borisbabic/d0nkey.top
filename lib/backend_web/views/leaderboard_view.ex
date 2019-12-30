defmodule BackendWeb.LeaderboardView do
  use BackendWeb, :view

  def render("index.html", %{
        invited: invited_raw,
        entry: entry_raw,
        conn: conn,
        region: region,
        leaderboard_id: leaderboard_id,
        updated_at: updated_at
      }) do
    invited =
      MapSet.new(
        invited_raw,
        fn ip ->
          String.splitter(ip.battletag_full, "#")
          |> Enum.at(0)
          |> to_string()
        end
      )

    # add qualified and qualifying
    # add qualified
    {entry, _} =
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

    old = updated_at && DateTime.diff(DateTime.utc_now(), updated_at) > 3600

    updated_at_string =
      updated_at
      |> DateTime.to_iso8601()
      |> String.splitter(".")
      |> Enum.at(0)
      |> String.replace("T", " ")

    render("index.html", %{
      conn: conn,
      entry: entry,
      region: region,
      leaderboard_id: leaderboard_id,
      old: old,
      updated_at: updated_at_string
    })
  end
end
