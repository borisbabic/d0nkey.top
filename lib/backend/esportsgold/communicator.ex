defmodule Backend.EsportsGold.Communicator do
  @moduledoc false

  alias Backend.EsportsGold.PlayerDetails

  @callback get_player_details(String.t()) :: PlayerDetails.t()
end
