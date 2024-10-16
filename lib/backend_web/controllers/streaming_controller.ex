defmodule BackendWeb.StreamingController do
  use BackendWeb, :controller
  @moduledoc false

  alias Backend.Streaming.StreamerDeckBag
  alias Backend.Streaming

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

  def order_by("best_legend_rank"), do: :best_legend_rank
  def order_by("worst_legend_rank"), do: :worst_legend_rank
  def order_by("latest_legend_rank"), do: :latest_legend_rank
  def order_by(_), do: :last_played

  defp direction("desc"), do: :desc
  defp direction("asc"), do: :asc
  defp direction(_), do: nil

  def streamer_decks(conn, %{"twitch_id" => "141981764"}) do
    conn
    |> put_view(BackendWeb.PageView)
    |> render("rick_roll.html", %{})
  end

  def streamer_decks(conn, params) do
    page_title =
      case params["twitch_login"] do
        nil -> "Streamer decks"
        tl -> "#{tl}'s decks"
      end

    attrs =
      base_streamer_deck_attrs(params)
      |> Map.merge(%{
        page_title: page_title,
        conn: conn
      })

    render(conn, "streamer_decks.html", attrs)
  end

  defp base_streamer_deck_attrs(params) do
    criteria =
      params
      |> Map.put_new("limit", 20)
      |> Map.put_new("order_by", {:desc, :last_played})
      |> Map.to_list()

    case Streaming.streamer_decks(criteria) do
      streamer_decks when is_list(streamer_decks) ->
        %{
          streamer_decks: Enum.take(streamer_decks, 20),
          archetypes: [],
          include_cards: [],
          exclude_cards: [],
          criteria: params |> Map.merge(%{"offset" => 0, "limit" => 20})
        }

      _ ->
        base_attrs_from_params(params)
    end
  end

  def base_attrs_from_params(params) do
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

    direction = direction(params["direction"])
    sort_by = params["sort_by"]

    criteria =
      %{
        "order_by" => {direction || :desc, sort_by |> order_by},
        "limit" => 20,
        "offset" => 0
      }
      |> Map.merge(params)
      |> Map.update!("limit", &(&1 |> Util.to_int_or_orig() |> min(50)))
      |> handle_old_peak_param()
      |> Map.put("include_cards", include_cards)
      |> Map.put("exclude_cards", exclude_cards)
      |> add_archetypes_filter(archetypes)

    streamer_decks = Streaming.streamer_decks(criteria)

    %{
      streamer_decks: streamer_decks,
      archetypes: archetypes,
      include_cards: include_cards,
      exclude_cards: exclude_cards,
      criteria: criteria
    }
  end

  # The params was renamed from legend to best_legend_rank.
  # I included other legend filters and wanted to keep it consistent in the queries
  defp handle_old_peak_param(params = %{"legend" => best}),
    do: params |> Map.put("best_legend_rank", best) |> Map.delete("legend")

  defp handle_old_peak_param(params), do: params
end
