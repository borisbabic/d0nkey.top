defmodule BackendWeb.StreamingController do
  use BackendWeb, :controller
  @moduledoc false

  def streamer_instructions(conn, params) do
    render(
      conn,
      "streamer_instructions.html",
      params |> Map.put(:page_title, "Streamer Instructions")
    )
  end

  def streamers_decks(conn, %{"twitch_login" => twitch_login}) do
    real_route =
      Routes.streaming_path(
        conn,
        :streamer_decks,
        Map.put(conn.query_params, "twitch_login", twitch_login)
      )

    redirect(conn, to: real_route)
  end

  defp add_archetypes_filter(criteria_map, archetypes),
    do: criteria_map |> Map.put("hsreplay_archetype", archetypes)

  def streamer_decks(conn, params) do
    # used to only be include cards, but then I added exclude_cards so cards is there for backwards compatibility
    include_cards =
      ["cards", "include_cards"]
      |> Enum.flat_map(fn p ->
        params[p]
        |> multi_select_to_array()
        |> Enum.map(&Util.to_int_or_orig/1)
      end)

    exclude_cards =
      multi_select_to_array(params["exclude_cards"])
      |> Enum.map(&Util.to_int_or_orig/1)

    archetypes =
      multi_select_to_array(params["hsreplay_archetypes"])
      |> Enum.map(&Util.to_int_or_orig/1)

    criteria =
      %{"order_by" => {:desc, :last_played}, "limit" => 50, "offset" => 0}
      |> Map.merge(params)
      |> handle_old_peak_param()
      |> Map.put("include_cards", include_cards)
      |> Map.put("exclude_cards", exclude_cards)
      |> add_archetypes_filter(archetypes)

    streamer_decks = Backend.Streaming.streamer_decks(criteria)
    streamers = Backend.Streaming.streamers(%{"order_by" => {:asc, :hsreplay_twitch_display}})

    page_title =
      case params["twitch_login"] do
        nil -> "Streamer decks"
        tl -> "#{tl}'s decks"
      end

    render(conn, "streamer_decks.html", %{
      streamer_decks: streamer_decks,
      conn: conn,
      streamers: streamers,
      archetypes: archetypes,
      page_title: page_title,
      include_cards: include_cards,
      exclude_cards: exclude_cards,
      criteria: criteria
    })
  end

  @doc """
  The params was renamed from legend to best_legend_rank.
  I included other legend filters and wanted to keep it consistent in the queries
  """
  defp handle_old_peak_param(params = %{"legend" => best}),
    do: params |> Map.put("best_legend_rank", best) |> Map.delete("legend")

  defp handle_old_peak_param(params), do: params
end
