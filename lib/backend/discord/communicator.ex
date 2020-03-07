defmodule Backend.Discord.Communicator do
  @callback broadcast_file(String.t(), String.t(), String.t()) :: any
end
