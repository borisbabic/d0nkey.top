defmodule Backend.HearthstoneJson.Communicator do
  @moduledoc false

  alias Backend.HearthstoneJson.Card

  @callback get_collectible_cards() :: [Card]
  @callback get_cards() :: [Card]
end
