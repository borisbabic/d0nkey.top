defmodule Bot.Consumer do
  use Nostrum.Consumer
  require Logger

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    Bot.MessageHandler.handle(msg)
  end

  def handle_event(_event) do
    :noop
  end
end
