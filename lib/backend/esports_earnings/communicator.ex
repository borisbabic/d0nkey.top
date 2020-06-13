defmodule Backend.EsportsEarnings.Communicator do
  @moduledoc false
  alias Backend.EsportsEarnings.PlayerDetails
  @callback get_all_highest_earnings_for_game(integer) :: [PlayerDetails]
end
