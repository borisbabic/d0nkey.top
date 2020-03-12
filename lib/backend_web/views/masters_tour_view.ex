defmodule BackendWeb.MastersTourView do
  use BackendWeb, :view
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.MastersTour
  alias Backend.Blizzard
  @type qualifiers_dropdown_link :: %{display: Blizzard.tour_stop(), link: String.t()}

  def render("qualifiers.html", %{fetched_qualifiers: qualifiers_raw, conn: conn, range: range}) do
    {before_range, after_range} = Util.get_surrounding_ranges(range)
    before_link = create_qualifiers_link(before_range, conn)
    after_link = create_qualifiers_link(after_range, conn)

    qualifiers =
      qualifiers_raw
      |> Enum.map(fn q ->
        q
        |> Map.put_new(:link, create_qualifier_link(q.slug, q.id))
        |> Map.put_new(:standings_link, Routes.battlefy_path(conn, :tournament, q.id))
      end)

    render("qualifiers.html", %{
      qualifiers: qualifiers,
      before_link: before_link,
      after_link: after_link,
      dropdown_links: create_dropdown_qualifier_links(conn)
    })
  end

  def render("invited_players.html", %{invited: invited, tour_stop: selected_ts, conn: conn}) do
    latest = Enum.find_value(invited, fn ip -> ip.upstream_time end)

    invited_players = Enum.map(invited, &process_invited_player/1)

    tour_stop_list =
      Backend.Blizzard.tour_stops()
      |> Enum.map(fn ts ->
        %{
          ts: ts,
          selected: to_string(ts) == to_string(selected_ts),
          link: Routes.masters_tour_path(conn, :invited_players, ts)
        }
      end)

    render("invited_players.html", %{
      invited_players: invited_players,
      ts_list: tour_stop_list,
      selected_ts: selected_ts,
      latest: latest
    })
  end

  @spec create_dropdown_qualifier_links(any) :: [qualifiers_dropdown_link]
  def create_dropdown_qualifier_links(conn) do
    tour_stop_ranges =
      Blizzard.tour_stops()
      |> Enum.reverse()
      |> Enum.take_while(fn ts -> ts != :Bucharest end)
      |> Enum.map(fn ts ->
        %{
          display: ts,
          link: ts |> MastersTour.guess_qualifier_range() |> create_qualifiers_link(conn)
        }
      end)

    date_ranges =
      [{:week, "Week"}, {:month, "Month"}]
      |> Enum.map(fn {range, display} ->
        %{
          display: display,
          link: MastersTour.get_masters_date_range(range) |> create_qualifiers_link(conn)
        }
      end)

    date_ranges ++ tour_stop_ranges
  end

  def create_qualifiers_link({%Date{} = from, %Date{} = to}, conn) do
    # Routes.masters_tour_path(conn, :qualifiers, %{"from" => from, "to" => to})
    # Routes.masters_tour_path(conn, :qualifiers, %{from: from, to: to})
    new_params =
      Map.merge(conn.query_params, %{"from" => Date.to_iso8601(from), "to" => Date.to_iso8601(to)})

    Routes.masters_tour_path(conn, :qualifiers, new_params)
  end

  @spec process_invited_player(%{
          battletag_full: String.t(),
          reason: String.t() | nil,
          tournament_slug: String.t() | nil,
          tournament_id: String.t() | nil,
          upstream_time: Calendar.datetime()
        }) :: %{
          battletag: String.t(),
          invited_at: String.t(),
          link: nil | String.t(),
          reason: String.t() | nil
        }
  def process_invited_player(
        invited_player = %{battletag_full: battletag_full, reason: reason_raw}
      ) do
    link =
      case invited_player do
        %{tournament_slug: slug, tournament_id: id} when is_binary(slug) and is_binary(id) ->
          create_qualifier_link(slug, id)

        _ ->
          nil
      end

    reason =
      case {invited_player.tournament_slug, reason_raw} do
        {slug, "qualifier"} when is_binary(slug) -> Recase.to_title(slug)
        _ -> reason_raw
      end

    battletag = InvitedPlayer.shorten_battletag(battletag_full)

    %{
      link: link,
      reason: reason,
      battletag: battletag,
      invited_at: invited_player.upstream_time
    }
  end

  @spec create_qualifier_link(String.t(), String.t()) :: String.t()
  def create_qualifier_link(slug, id) do
    "https://battlefy.com/hsesports/#{slug}/#{id}/info"
  end
end
