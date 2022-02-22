defmodule TwitchBot.Util do
  def parse_chat("#" <> chat), do: chat
  def parse_chat(chat), do: chat
end
