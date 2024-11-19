defmodule TwitchBot.Handler do
  import TwitchBot.Util
  use TMI

  @type message_info :: %{
          message: String.t(),
          sender: String.t(),
          chat: String.t()
        }
  @impl TMI.Handler
  def handle_message(message, sender, chat) do
    config = chat |> parse_chat() |> Backend.TwitchBot.commands()

    message_info = %{
      message: message,
      sender: sender,
      chat: chat
    }

    matching = TwitchBot.MessageMatcher.match(config, message_info)
    responses = TwitchBot.MessageCreator.create_messages(matching, message_info)
    Enum.each(responses, &TMI.message(chat, &1))
  end
end
