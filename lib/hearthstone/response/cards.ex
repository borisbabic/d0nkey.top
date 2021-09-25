defmodule Hearthstone.Response.Cards do
  @moduledoc false

  use TypedStruct

  alias Hearthstone.Card

  typedstruct enforce: true do
    field :cards, Card.t()
    field :card_count, integer()
    field :page, integer()
    field :page_count, integer()
  end

  def from_raw_map(%{
        "cardCount" => card_count,
        "cards" => cards_raw,
        "page" => page,
        "pageCount" => page_count
      }) do
    with {:ok, cards} <- Util.map_abort_on_error(cards_raw, &Card.from_raw_map/1) do
      {
        :ok,
        %__MODULE__{
          cards: cards,
          card_count: card_count,
          page: page,
          page_count: page_count
        }
      }
    end
  end

  def from_raw_map(_), do: {:error, :unable_to_parse_cards_response}
end
