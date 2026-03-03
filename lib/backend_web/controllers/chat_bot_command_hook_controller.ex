defmodule BackendWeb.ChatBotCommandHookController do
  @moduledoc "for use with ${customapi} (streamelements)) and $(urlfetch) (nightbot)"
  use BackendWeb, :html_controller
  plug(:put_layout, false)
  alias Hearthstone.DeckcodeExtractor
  alias Bot.LdbMessageHandler
  alias Backend.Blizzard
  alias Backend.Infrastructure.BlizzardCommunicator, as: BlizzApi
  alias Backend.LatestHSArticles

  def deck_url(conn, %{"channel" => _, "deckcode" => deckcode_raw}) do
    deckcode =
      if is_list(deckcode_raw) do
        Enum.join(deckcode_raw, "/")
      else
        deckcode_raw
      end

    with [deck] <- DeckcodeExtractor.performant_extract_from_text(deckcode),
         {:ok, %{id: id}} <- Backend.Hearthstone.create_or_get_deck(deck) do
      conn |> put_status(200) |> text("https://www.hsguru.com/deck/#{id}")
    else
      _ -> conn |> put_status(400)
    end
  end

  def hearthstone_news(conn, %{"channel" => _, "options" => options}) do
    tags =
      options
      |> String.split(" ")
      |> Enum.drop(1)

    LatestHSArticles.get()
    |> LatestHSArticles.filter_tags(tags)
    |> case do
      [article | _] ->
        message = "#{LatestHSArticles.title(article)} - #{LatestHSArticles.url(article)}"

        conn
        |> put_status(200)
        |> text(message)

      _ ->
        conn |> put_status(400)
    end
  end

  def deck_url(conn, _params) do
    conn
    |> put_status(400)
  end

  def leaderboard_count(conn, %{
        "channel" => _,
        "default_leaderboard_id" => default_leaderboard_id,
        "leaderboard_id" => leaderboard_id
      }) do
    options_fallbacks = add_default_leaderboard_id(%{}, default_leaderboard_id)

    %{leaderboard_id: ldb_id} =
      LdbMessageHandler.parse_leaderboard_options(
        leaderboard_id,
        options_fallbacks
      )

    message = create_ldbc_message(ldb_id)

    conn
    |> put_status(200)
    |> text(message)
  end

  def create_ldbc_message(ldb_id) do
    seasons =
      Backend.Leaderboards.current_ladder_seasons()
      |> Enum.flat_map(fn season ->
        with true <- to_string(season.leaderboard_id) == to_string(ldb_id),
             {:ok, %{total_size: ts} = s} when is_integer(ts) and ts > 0 <-
               Backend.Leaderboards.get_season(season) do
          [s]
        else
          _ -> []
        end
      end)

    # if more seasons, like end of month, specify which it is
    include_season_part? = 1 < Enum.uniq_by(seasons, & &1.season_id) |> Enum.count()

    seasons_part =
      Enum.map_join(seasons, ", ", fn %{region: region, total_size: total_size} = s ->
        season_part =
          if include_season_part? do
            name = Blizzard.get_season_name(s.season_id, s.leaderboard_id)
            " #{name}"
          end

        "#{Blizzard.get_region_name(region)}#{season_part} - #{total_size}"
      end)

    "#{Blizzard.get_leaderboard_name(ldb_id, :long)} counts: #{seasons_part}"
  end

  def leaderboard(conn, %{
        "channel" => _,
        "options" => options
      }) do
    message = leaderboard_message(options)

    conn
    |> put_status(200)
    |> text(message)
  end

  def leaderboard_message(options) do
    {battletags, criteria} = LdbMessageHandler.battletags_and_criteria("!ldb " <> options)

    LdbMessageHandler.get_leaderboard_entries(battletags, criteria)
    |> Enum.map_join(", ", fn {entries, r, l} ->
      season_part =
        "#{Blizzard.get_region_name(r, :short)} #{Blizzard.get_leaderboard_name(l, :short)}"

      entries_part = entries_part(entries, l)
      "#{season_part}: #{entries_part}"
    end)
  end

  def entries_part(entries, leaderboard_id) do
    Enum.map_join(entries, " ", fn %{rank: rank, account_id: account_id, rating: rating} ->
      rating_part = rating_part(rating, leaderboard_id)
      "#{rank}. #{account_id}#{rating_part}"
    end)
  end

  def rating_part(rating, leaderboard_id) when is_number(rating) do
    display = Backend.Leaderboards.rating_display(rating, leaderboard_id)
    " (#{display})"
  end

  def rating_part(_, _), do: ""

  def top_25(conn, %{
        "channel" => _,
        "default_region" => default_region,
        "default_leaderboard_id" => default_leaderboard_id,
        "options" => options
      }) do
    message = top_25_options_to_message(options, default_region, default_leaderboard_id)

    conn
    |> put_status(200)
    |> text(message)
  end

  def top_25_options_to_message(options, default_region \\ "EU", default_leaderboard_id \\ "STD") do
    options_fallbacks =
      %{}
      |> add_default_region(default_region)
      |> add_default_leaderboard_id(default_leaderboard_id)

    LdbMessageHandler.get_top_leaderboard_entries_season_info(
      "!ldb-top " <> options,
      options_fallbacks
    )
    |> create_top_25_message()
  end

  def create_top_25_message({entries, season_info}) do
    count = Enum.count(entries)
    leaderboard = season_info.leaderboard_id |> Blizzard.get_leaderboard_name(:long)
    region = season_info.region |> Blizzard.get_region_name()

    entries_part = entries_part(entries, season_info.leaderboard_id)

    "Top #{count} players #{region} - #{leaderboard}: #{entries_part}"
  end

  defp add_default_region(options, default) do
    case Blizzard.to_region(default) do
      {:ok, r} -> Map.put(options, :region, r)
      _ -> options
    end
  end

  defp add_default_leaderboard_id(options, default) do
    case Blizzard.to_leaderboard_id(default) do
      {:ok, id} -> Map.put(options, :leaderboard_id, id)
      _ -> options
    end
  end

  def next_reveal(conn, %{"channel" => _} = params) do
    mode = parse_mode(params)
    locale = Map.get(params, "locale", "en")
    reveals = BlizzApi.reveal_schedule(mode)

    case Bot.RevealMessageHandler.filter_current(reveals, 1, 0) do
      [%{url: url, reveal_time: reveal_time} = reveal | _] ->
        prepend = Bot.RevealMessageHandler.extract_prepend(reveal)
        time_part = time_part(reveal_time, locale)
        conn |> put_status(200) |> text("[#{prepend}] - #{time_part} - #{url}")

      _ ->
        conn |> put_status(200) |> text("no (supported) reveals upcoming")
    end
  end

  def next_reveal(conn, _params) do
    conn
    |> put_status(400)
  end

  defp time_part(reveal_time, locale) do
    reveal_time
    |> Timex.diff(NaiveDateTime.utc_now())
    |> Timex.Duration.from_microseconds()
    |> Timex.Duration.to_minutes()
    |> Float.round()
    |> Timex.Duration.from_minutes()
    |> Timex.Format.Duration.Formatters.Humanized.lformat(locale)
  end

  defp parse_mode(%{"mode" => mode})
       when mode in ["bg", "bgs", "BG", "BGS", "battlegrounds", "battleground"],
       do: :bgs

  defp parse_mode(_), do: :constructed

  def help(conn, _params) do
    render(conn, :help)
  end
end
