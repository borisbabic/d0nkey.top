defmodule BackendWeb.HSReplayView do
  use BackendWeb, :view
  alias Backend.HSReplay

  def player_rank(51, legend), do: "L#{legend}"

  def player_rank(rank, _) do
    material =
      case div(rank - 1, 10) do
        4 -> "D"
        3 -> "P"
        2 -> "G"
        1 -> "S"
        0 -> "B"
        _ -> "?"
      end

    in_material_rank = rem(10 - rem(rank, 10), 10) + 1
    "#{material}#{in_material_rank}"
  end

  def extract_ranks(entry) do
    {
      player_rank(entry.player1_rank, entry.player1_legend_rank),
      player_rank(entry.player2_rank, entry.player2_legend_rank)
    }
  end

  #  def render("matchups.html", %{matchups: matchups, as: as, vs: vs, archetypes: archetypes}) do
  #
  #    render("matchups.html", {rows: [[1, 2], [2,3]]})
  #  end

  def render("matchups.html", %{
        matchups: matchups,
        as: as,
        vs: vs,
        archetypes: archetypes
      }) do
    get_name = fn arch ->
      %{style: "", value: archetypes |> Enum.find(fn a -> a.id == arch end) |> Map.get(:name)}
    end

    rows = [
      [%{value: "", style: ""} | vs |> Enum.map(get_name)]
      | as
        |> Enum.map(fn as_arch ->
          [
            get_name.(as_arch)
            | vs
              |> Enum.map(fn vs_arch ->
                case Backend.HSReplay.ArchetypeMatchups.get_matchup(matchups, as_arch, vs_arch) do
                  %{win_rate: win_rate} ->
                    red = 255 - 255 * (win_rate / 100)
                    green = 255 * (win_rate / 100)
                    blue = min(red, green)

                    %{
                      value: win_rate,
                      style: "background-color: rgb(#{red}, #{green}, #{blue})"
                    }

                  nil ->
                    %{
                      value: "?",
                      style: "background-color: rgb(150, 150, 150)"
                    }
                end
              end)
          ]
        end)
    ]

    render("matchups.html", %{rows: rows})
  end

  def render("matchups_empty.html", _params) do
    "You need to add the as and vs query params.
    Example \"d0nkey.top/hsreplay/matchups?as[]=146&vs[]=344\" or \"d0nkey.top/hsreplay/matchups?as[]=highlander
    mage&vs[]=galakrond rogue\" for
    highlander mage vs gally rogue
    Exact names and numbers are based on hsreplay data
    You can also use the bot in the discord (example: !matchups_link highlander mage, pirate warrior vs galakrond
    rogue, highlander hunter)
    All data is the default free data.
    "
  end
end
