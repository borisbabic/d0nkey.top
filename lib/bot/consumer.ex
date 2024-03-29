defmodule Bot.Consumer do
  @moduledoc false
  use Nostrum.Consumer
  use Bot.SlashCommandHandler
  require Logger

  def start_link do
    start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    Bot.MessageHandler.handle(msg)
  end

  def handle_event(_event) do
    :noop
  end
end
