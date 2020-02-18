defmodule BackendWeb.HSReplayView do
  use BackendWeb, :view
  alias Backend.HSReplay

  def render("live_feed.html", %{feed: feed, archetypes: archetypes}) do
    archetype_map =
      archetypes
      |> Enum.reduce(%{}, fn a, acc ->
        acc |> Map.put_new(a.id, a.name)
      end)

    replays =
      feed
      |> Enum.map(fn f ->
        %{
          url: HSReplay.create_replay_link(f.id),
          p1deck: Map.get(archetype_map, f.player1_archetype, "Unknown"),
          p1rank: f.player1_rank || "L#{f.player1_legend_rank}",
          p2deck: Map.get(archetype_map, f.player2_archetype, "Unknown"),
          p2rank: f.player2_rank || "L#{f.player2_legend_rank}",
          p1won: f.player1_won,
          p2won: f.player2_won
        }
      end)
      |> Enum.reverse()

    render("live_feed.html", %{replays: replays})
  end

  #  def render("matchups.html", %{matchups: matchups, as: as, vs: vs, archetypes: archetypes}) do
  #
  #    render("matchups.html", {rows: [[1, 2], [2,3]]})
  #  end

  def render("matchups.html", %{
        matchups: matchups,
        as: as_string,
        vs: vs_string,
        archetypes: archetypes
      }) do
    get_name = fn arch ->
      %{style: "", value: archetypes |> Enum.find(fn a -> a.id == arch end) |> Map.get(:name)}
    end

    as = as_string |> Enum.map(&Util.to_int_or_orig/1)
    vs = vs_string |> Enum.map(&Util.to_int_or_orig/1)

    rows = [
      [%{value: "", style: ""} | vs |> Enum.map(get_name)]
      | as
        |> Enum.map(fn as_arch ->
          [
            get_name.(as_arch)
            | vs
              |> Enum.map(fn vs_arch ->
                win_rate =
                  Backend.HSReplay.ArchetypeMatchups.get_matchup(matchups, as_arch, vs_arch).win_rate

                red = 255 - 255 * (win_rate / 100)
                green = 255 * (win_rate / 100)
                blue = min(red, green)

                %{
                  value: win_rate,
                  style: "background-color: rgb(#{red}, #{green}, #{blue})"
                }
              end)
          ]
        end)
    ]

    render("matchups.html", %{rows: rows})
  end

  def render("matchups_empty.html", _params) do
    "You need to add the as and vs query string.
    Example as[]=146&vs[]=344 for highlander mage vs gally rogue
    You can find the correct numbers needed in the url of the archetype on hsreplay.
    You can also use the bot in the discord (example: !matchups_link highlander mage, pirate warrior vs galakrond
    rogue, highlander hunter)
    All data is the default free data.
    "
  end
end
