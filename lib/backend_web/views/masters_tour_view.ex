defmodule BackendWeb.MastersTourView do
  use BackendWeb, :view
  alias Backend.MastersTour.InvitedPlayer

  def render("qualifiers.html", %{fetched_qualifiers: qualifiers_raw}) do
    qualifiers =
      qualifiers_raw
      |> Enum.map(fn q -> Map.put_new(q, :link, create_qualifier_link(q.slug, q.id)) end)

    render("qualifiers.html", %{qualifiers: qualifiers})
  end

  def render("invited_players.html", %{invited: invited, tour_stop: selected_ts, conn: conn}) do
    latest =
      case Enum.find_value(invited, fn ip -> ip.upstream_time end) do
        nil -> nil
        ut -> Util.datetime_to_presentable_string(ut)
      end

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
      invited_at: Util.datetime_to_presentable_string(invited_player.upstream_time)
    }
  end

  @spec create_qualifier_link(String.t(), String.t()) :: String.t()
  def create_qualifier_link(slug, id) do
    "https://battlefy.com/hsesports/#{slug}/#{id}/info"
  end
end
