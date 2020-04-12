defmodule Backend.Discord.Communicator do
  @moduledoc false
  @callback broadcast_file(String.t(), String.t(), String.t()) :: any
end
