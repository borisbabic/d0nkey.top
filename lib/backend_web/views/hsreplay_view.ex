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
end
