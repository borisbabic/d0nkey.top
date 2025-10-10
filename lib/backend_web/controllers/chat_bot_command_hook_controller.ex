defmodule BackendWeb.ChatBotCommandHookController do
  use BackendWeb, :html_controller
  @moduledoc "for use with ${customapi} (streamelements)) and $(urlfetch) (nightbot)"
  alias Hearthstone.DeckcodeExtractor
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
end
