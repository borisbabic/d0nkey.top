defmodule TwitchBot.Handler do
  @moduledoc "Handles incoming twitch chat messages"
  use TMI
  import TwitchBot.Util

  @type message_info :: %{
          message: String.t(),
          sender: String.t(),
          chat: String.t()
        }
  @impl TMI.Handler
  def handle_message(message, sender, chat, tags \\ :no_tags) do
    config = chat |> parse_chat() |> Backend.TwitchBot.commands()

    message_info = %{
      message: message,
      sender: sender,
      chat: chat,
      tags: tags
    }

    broadcast_new_message(message_info)

    matching = TwitchBot.MessageMatcher.match(config, message_info)
    responses = TwitchBot.MessageCreator.create_messages(matching, message_info)
    for {:ok, message} <- responses, do: say(chat, message)
  end

  defp broadcast_new_message(base_info) do
    message_info = ensure_id(base_info)

    topic(message_info.chat)
    |> BackendWeb.Endpoint.broadcast("new_message", %{message_info: message_info})
  end

  defp ensure_id(%{id: id} = info) when is_binary(id) or is_integer(id) do
    info
  end

  defp ensure_id(%{tags: %{"id" => id}} = info) when is_binary(id) or is_integer(id) do
    Map.put(info, :id, id)
  end

  defp ensure_id(%{message: message, sender: sender, chat: chat} = info) do
    Map.put(info, :id, chat <> sender <> now_iso() <> message)
  end

  defp now_iso(), do: NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601()

  def subscribe_to_chat(chat) do
    chat
    |> topic()
    |> BackendWeb.Endpoint.subscribe()
  end

  def topic(chat) do
    "twitch:chat:" <> normalize_chat(chat)
  end

  def normalize_chat("#" <> _ = chat), do: String.downcase(chat)
  def normalize_chat(chat), do: ("#" <> chat) |> normalize_chat()
end
