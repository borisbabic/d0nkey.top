defmodule TwitchBot.Handler do
  use TMI.Handler
  @type message_info :: %{
    message: String.t(),
    sender: String.t(),
    chat: String.t(),
    config: [TwitchBot.ConfigManager.message_config()]
  }
  @impl true
  def handle_message(message, sender, chat) do
    config =  TwitchBot.ConfigManager.config(chat)
    message_info = %{
      message: message,
      sender: sender,
      chat: chat,
    }

    matching = TwitchBot.MessageMatcher.match(config, message_info)
    IO.inspect(matching, label: "matching")
    responses = TwitchBot.MessageCreator.create_messages(matching, message_info)
    IO.inspect(responses, label: "resposnes")
    Enum.each(responses, & TMI.message(chat, &1))
  end
end
