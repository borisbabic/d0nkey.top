defmodule BackendWeb.ChatBotCommandHookController do
  @moduledoc "for use with ${customapi} (streamelements)) and $(urlfetch) (nightbot)"
  use BackendWeb, :html_controller
  plug(:put_layout, false)
  alias Hearthstone.DeckcodeExtractor
  alias Bot.LdbMessageHandler
  alias Backend.Blizzard
  alias Backend.Infrastructure.BlizzardCommunicator, as: BlizzApi

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

  def deck_url(conn, _params) do
    conn
    |> put_status(400)
  end

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

    entries_part =
      Enum.map_join(entries, " ", fn %{rank: rank, account_id: account_id} ->
        "#{rank}. #{account_id}"
      end)

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
