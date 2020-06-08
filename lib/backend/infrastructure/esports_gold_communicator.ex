defmodule Backend.Infrastructure.EsportsGoldCommunicator do
  @moduledoc false
  @behaviour Backend.EsportsGold.Communicator
  import Backend.Infrastructure.CommunicatorUtil
  alias Backend.EsportsGold.PlayerDetails

  def get_player_details(bt) do
    raw =
      get_body(
        "https://api.esportsgold.com/api/player/esport/hs/playerdetails/#{String.downcase(bt)}"
      )
      |> Poison.decode!()

    case raw["data"]["player"]["details"] do
      # this is the wrong way to solve this but who cares :sweat_smile:
      nil -> PlayerDetails.from_alias(bt)
      details -> PlayerDetails.from_raw_map(details)
    end
  end
end
