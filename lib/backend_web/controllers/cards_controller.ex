defmodule BackendWeb.CardsController do
  use BackendWeb, :html_controller
  alias Backend.Hearthstone, as: HS

  def dust_free(conn, _params) do
    cards = Backend.Hearthstone.cards([:dust_free])
    render(conn, :ids, cards: cards)
  end

  def all(conn, params) do
    criteria = Enum.to_list(params)
    cards = Backend.Hearthstone.cards(criteria)
    render(conn, :cards, cards: cards)
  end

  def collectible(conn, params) do
    criteria = Enum.to_list(params)
    cards = Backend.Hearthstone.cards([{"collectible", true} | criteria])
    render(conn, :cards, cards: cards)
  end

  def metadata(conn, _params) do
    metadata = %{
      card_back_categories: HS.card_back_categories(),
      classes: HS.classes(),
      game_modes: HS.game_modes(),
      keywords: HS.keywords(),
      mercenary_roles: HS.mercenary_roles(),
      minion_types: HS.minion_types(),
      set_groups: HS.set_groups(),
      sets: HS.card_sets(),
      spell_schools: HS.spell_schools(),
      types: HS.card_types()
    }

    render(conn, :metadata, metadata: metadata)
  end
end
