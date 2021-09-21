defmodule Backend.HearthstoneJson.Communicator do
  @moduledoc false

  alias Backend.HearthstoneJson.Card

  @callback get_collectible_cards() :: {:ok, [Card]} | {:error, any()}
  @callback get_cards!() :: [Card]
  @callback get_cards() :: {:ok, [Card]} | {:error, any()}
end
