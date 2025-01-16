defmodule Bot.RevealMessageHandler do
  @moduledoc "Handles messages related to hearthstone card reveals"
  alias Backend.Infrastructure.BlizzardCommunicator, as: BlizzApi
  import Bot.MessageHandlerUtil
  alias Nostrum.Struct.Embed
  alias Nostrum.Api

  def handle_reveals(msg, mode \\ :constructed) do
    response =
      reveals(mode)
      |> filter_current(3)
      |> create_response(msg)

    Api.create_message(msg.channel_id, response)
  end

  def handle_all_reveals(msg, mode \\ :constructed) do
    response =
      reveals(mode)
      |> create_response(msg)

    Api.create_message(msg, response)
  end

  def filter_current(reveals, minimum \\ 3) do
    now = NaiveDateTime.utc_now()
    start_period = NaiveDateTime.add(now, -1 * 60 * 60)
    end_period = NaiveDateTime.add(now, 24 * 60 * 60)

    after_start =
      reveals |> Enum.drop_while(&(:gt == NaiveDateTime.compare(start_period, &1.reveal_time)))

    min_reveals = Enum.take(after_start, minimum)

    additional =
      after_start
      |> Enum.drop(minimum)
      |> Enum.take_while(&(:gt == NaiveDateTime.compare(end_period, &1.reveal_time)))

    min_reveals ++ additional
  end

  def create_response(reveals, msg) do
    case format(msg) do
      "embed" -> [embeds: Enum.map(reveals, &to_embed/1)]
      _ -> [content: Enum.map_join(reveals, "\n", &to_text/1)]
    end
  end

  def format(msg) do
    msg
    |> get_options()
    |> Enum.find_value("text", fn
      "format:" <> format -> format
      _ -> false
    end)
  end

  def to_text(%{url: url, reveal_time: reveal_time} = reveal) do
    {:ok, datetime} = DateTime.from_naive(reveal_time, "UTC")
    timestamp = DateTime.to_unix(datetime)

    prepend_part =
      with prepend when is_binary(prepend) <- extract_prepend(reveal) do
        "[#{prepend}] "
      end

    "* #{prepend_part}<t:#{timestamp}:F> <#{url}>"
  end

  defp extract_prepend(%{class: class}) when is_binary(class), do: class

  defp extract_prepend(%{image_url: image_url}) when is_binary(image_url) do
    # https://.../31p4_Icon_Zerg.png into ["Icon", "Zerg"]
    parts =
      String.split(image_url, "/")
      |> Enum.at(-1)
      |> String.replace(".png", "")
      |> String.split("_")
      |> Enum.drop(1)

    case parts do
      [] -> nil
      ["Icon" | rest] -> Enum.join(rest, " ")
      rest -> Enum.join(rest, " ")
    end
  end

  defp extract_prepend(_), do: nil

  def to_embed(%{url: url, image_url: image_url, reveal_time: reveal_time}) do
    title = if url == "", do: nil, else: "Reveal Link"

    %Embed{
      url: url,
      title: title,
      timestamp: reveal_time
    }
    |> Embed.put_image(image_url)
  end

  ""

  def reveals(mode), do: BlizzApi.reveal_schedule(mode)
end
