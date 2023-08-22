defmodule BackendWeb.MastersTour.MastersToursStats do
  @moduledoc false
  use BackendWeb, :view
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.TournamentStats.TournamentTeamStats
  alias Backend.TournamentStats.TeamStats
  alias Backend.MastersTour
  alias Backend.MastersTour.TourStop
  alias Backend.PlayerInfo
  alias BackendWeb.ViewUtil
  import BackendWeb.SortHelper

  defp create_stats_header("#", _, _, _), do: "#"

  defp create_stats_header(header, sort_by, direction, conn) when header == sort_by do
    click_params = %{"sort_by" => header, "direction" => opposite(direction)}

    url =
      Routes.masters_tour_path(
        conn,
        :masters_tours_stats,
        Map.merge(conn.query_params, click_params)
      )

    cell = "#{header}#{symbol(direction)}"

    ~E"""
      <a class="is-text" href="<%= url %>"><%= cell %></a>
    """
  end

  defp create_stats_header(header, _, _, conn) do
    click_params = %{"sort_by" => header, "direction" => :desc}

    url =
      Routes.masters_tour_path(
        conn,
        :masters_tours_stats,
        Map.merge(conn.query_params, click_params)
      )

    ~E"""
      <a class="is-text" href="<%= url %>"><%= header %></a>
    """
  end

  defp filter_columns(column_map, columns_to_show) do
    columns_to_show
    |> Enum.map(fn c -> column_map[c] || "" end)
  end

  defp tournament_score_cell(score, name, tournament_id, conn) do
    link = Routes.battlefy_path(conn, :tournament_player, tournament_id, name)

    ~E"""
    <a class="is-link" href="<%= link %>"><%= score %></a>
    """
  end

  defp create_player_rows(player_stats, conn) do
    player_stats
    |> Enum.map(fn {player_name, tts} ->
      total = tts |> Enum.count()

      {flag, country} =
        with nil <- PlayerInfo.get_country(player_name),
             nil <- Util.get_country_code(player_name) do
          {"", nil}
        else
          cc -> {country_flag(cc, player_name), cc}
        end

      profile_name = MastersTour.mt_profile_name(player_name)
      profile_link = Routes.player_path(conn, :player_profile, profile_name)

      player_cell = ~E"""

      <span><%= flag %></span> <a class="is-link" href="<%= profile_link %>">
        <%= player_name %>
      </a>
      """

      {swiss_stats_list, ts_rows} =
        tts
        |> Enum.map_reduce(%{}, fn ts, acc ->
          swiss = ts |> TournamentTeamStats.filter_stages(:swiss)

          {swiss,
           Map.put_new(
             acc,
             TourStop.get_by(:battlefy_id, ts.tournament_id)
             |> TourStop.display_name()
             |> masters_tour_column_name(),
             "#{swiss.wins} - #{swiss.losses}"
             |> tournament_score_cell(ts.team_name, ts.tournament_id, conn)
           )}
        end)

      swiss = swiss_stats_list |> TeamStats.calculate_team_stats()

      stats =
        tts |> Enum.map(&TournamentTeamStats.total_stats/1) |> TeamStats.calculate_team_stats()

      %{
        "Player" => player_cell,
        :country => country,
        "Tour Stops" => total,
        "Top 8" => stats.positions |> Enum.filter(fn p -> p < 9 end) |> Enum.count(),
        "Best" => stats |> TeamStats.best(),
        "Worst" => stats |> TeamStats.worst(),
        "Median" => stats |> TeamStats.median(),
        "Tour Stops Won" => stats.positions |> Enum.filter(fn p -> p == 1 end) |> Enum.count(),
        "Num Swiss Matches" => swiss.wins + swiss.losses,
        "Swiss Matches Won" => swiss.wins,
        "Swiss Matches Lost" => swiss.losses,
        "Swiss Winrate %" => swiss |> TeamStats.matches_won_percent() |> Float.round(2),
        "Num Matches" => stats.wins + stats.losses,
        "Matches Won" => stats.wins,
        "Matches Lost" => stats.losses,
        "Winrate %" => stats |> TeamStats.matches_won_percent() |> Float.round(2)
      }
      |> Map.merge(ts_rows)
    end)
  end

  defp process_sorting(sort_by_raw, direction_raw) do
    case {sort_by_raw, direction_raw} do
      {s, d} when is_atom(d) and is_binary(s) -> {s, d}
      {s, _} when is_binary(s) -> {s, :desc}
      _ -> {"Matches Won", :desc}
    end
  end

  defp masters_tour_column_name(name), do: masters_tour_name_fixer(name) <> " swiss"

  @spec masters_tour_name_fixer(String.t()) :: String.t()
  def masters_tour_name_fixer(name),
    do: ~r/^Master(s)? Tour( Online: )?/ |> Regex.replace(to_string(name), "")

  def create_grouping_func("country") do
    fn n ->
      n
      |> get_mt_name()
      |> PlayerInfo.get_country()
      |> Util.get_country_name()
    end
  end

  def create_grouping_func("region") do
    fn n ->
      n
      |> get_mt_name()
      |> PlayerInfo.get_region()
      |> case do
        nil -> "Unknown/Other"
        r -> Backend.Blizzard.get_region_name(r, :long)
      end
    end
  end

  def create_grouping_func("max_nations_2022") do
    downcase_roster_map =
      Backend.MaxNations2022.rosters()
      |> Enum.flat_map(fn {country, country_roster} ->
        Enum.map(country_roster, fn btag ->
          {
            btag |> get_mt_name() |> String.downcase(),
            country
          }
        end)
      end)
      |> Map.new()

    fn n ->
      normalized_name = n |> get_mt_name() |> String.downcase()
      Map.get(downcase_roster_map, normalized_name)
    end
  end

  def create_grouping_func("max_nations_2022_groups") do
    group_map =
      Backend.MaxNations2022.first_stage_groups()
      |> Enum.flat_map(fn {group, countries} ->
        Enum.map(countries, &{&1, "Group #{group}"})
      end)
      |> Map.new()

    nations_grouping = create_grouping_func("max_nations_2022")

    fn n ->
      case nations_grouping.(n) do
        nil -> nil
        nation -> Map.get(group_map, nation)
      end
    end
  end

  def create_grouping_func(_), do: &get_mt_name/1

  defp get_mt_name(n),
    do:
      n
      |> InvitedPlayer.shorten_battletag()
      |> MastersTour.fix_name()

  def render("masters_tours_stats.html", %{
        conn: conn,
        sort_by: sort_by_raw,
        direction: direction_raw,
        selected_columns: selected_columns,
        years: years,
        tour_stops: tour_stops,
        countries: countries,
        group_by: group_by,
        tournament_team_stats: tts
      }) do
    {sort_by, direction} = process_sorting(sort_by_raw, direction_raw)

    update_link = fn new_params ->
      Routes.masters_tour_path(
        conn,
        :masters_tours_stats,
        conn.query_params |> Map.merge(new_params)
      )
    end

    %{
      limit: limit,
      offset: offset,
      prev_button: prev_button,
      next_button: next_button,
      dropdown: limit_dropdown
    } =
      ViewUtil.handle_pagination(conn.query_params, update_link,
        default_limit: 200,
        limit_options: [50, 100, 150, 200, 250, 300, 350, 500, 750, 1000, 2000, 3000]
      )

    columns =
      [
        "Player"
      ] ++
        (tour_stops
         |> Enum.map(fn ts ->
           ts
           |> TourStop.display_name()
           |> masters_tour_column_name()
         end)) ++
        [
          "Tour Stops",
          "Won",
          "Top 8",
          "Best",
          "Worst",
          "Median",
          "Num Swiss Matches",
          "Swiss Matches Won",
          "Swiss Matches Lost",
          "Swiss Winrate %",
          "Num Matches",
          "Matches Won",
          "Matches Lost",
          "Winrate %"
        ]

    columns_to_show =
      if is_list(selected_columns) && Enum.count(selected_columns) > 0 do
        columns |> Enum.filter(fn c -> Enum.member?(selected_columns, c) end)
      else
        ["Player", "Tour Stops", "Top 8", "Matches Won", "Matches Lost", "Winrate %"]
      end

    sort_key = columns |> Enum.find("Matches Won", fn h -> h == sort_by end)

    rows =
      tts
      |> Backend.TournamentStats.create_team_stats_collection(create_grouping_func(group_by))
      |> Enum.filter(fn {name, _} ->
        name &&
          (countries == nil || countries == [] ||
             PlayerInfo.get_country(name) in countries)
      end)
      |> create_player_rows(conn)
      |> Enum.sort_by(fn row -> row[sort_key] end, direction || :desc)
      |> Enum.with_index(1)
      |> Enum.drop(offset)
      |> Enum.take(limit)
      |> Enum.map(fn {row, pos} -> [pos | filter_columns(row, columns_to_show)] end)

    years_options = years_options(years)

    columns_options =
      columns
      |> Enum.map(fn h ->
        %{
          selected: h in columns_to_show,
          display: h,
          name: h,
          value: h
        }
      end)

    headers =
      (["#"] ++ columns_to_show)
      |> Enum.map(fn h -> create_stats_header(h, sort_by, direction, conn) end)

    render("masters_tours_stats.html", %{
      headers: headers,
      rows: rows,
      columns_options: columns_options,
      years_options: years_options,
      conn: conn,
      selected_countries: countries,
      prev_button: prev_button,
      next_button: next_button,
      dropdowns: [limit_dropdown, create_group_by_dropdown(group_by, update_link)]
    })
  end

  defp create_group_by_dropdown(group_by, update_params) do
    options =
      [{"country", "Country"}, {"region", "Region"}, {"player", "Player"}]
      |> Enum.map(fn {val, display} ->
        %{
          selected: group_by == val,
          display: display,
          link: update_params.(%{"group_by" => val})
        }
      end)

    {options, "Group By"}
  end

  defp years_options(years) do
    MastersTour.eligible_stats_years()
    |> Enum.map(&to_string(&1))
    |> Enum.map(fn y ->
      %{
        selected: !Enum.any?(years) || y in years,
        display: y,
        name: y,
        value: y
      }
    end)
  end
end
