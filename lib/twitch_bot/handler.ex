defmodule TwitchBot.Handler do
  use TMI
  import TwitchBot.Util

  @type message_info :: %{
          message: String.t(),
          sender: String.t(),
          chat: String.t()
        }
  @impl TMI.Handler
  def handle_message(message, sender, chat, _tags \\ :no_tags) do
    config = chat |> parse_chat() |> Backend.TwitchBot.commands()

    message_info = %{
      message: message,
      sender: sender,
      chat: chat
    }

    matching = TwitchBot.MessageMatcher.match(config, message_info)
    responses = TwitchBot.MessageCreator.create_messages(matching, message_info)
    for {:ok, message} <- responses, do: say(chat, message)
  end
end
