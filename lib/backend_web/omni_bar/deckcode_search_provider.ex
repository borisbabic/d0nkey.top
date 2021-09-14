defmodule BackendWeb.DeckcodeSearchProvider do
  @behaviour OmniBar.SearchProvider
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone
  alias OmniBar.Result
  alias BackendWeb.Router.Helpers, as: Routes
  alias BackendWeb.DeckviewerLive

  def search(term, callback) do
    case Deck.decode(term) do
      {:ok, deck} -> handle_valid_deck(deck, term, callback)
      _ -> nil
    end
  end

  defp handle_valid_deck(deck, term, callback) do
    with false <- deckviewer_result(deck, term) |> callback.(),
         d = %{id: _deck_id} <- Hearthstone.deck(deck) do
      d
    end
  end

  def deckviewer_result(deck, term) do
    code = Deck.deckcode(deck)

    %Result{
      search_term: term,
      display_value: "View in Deckviewer",
      priority: 1,
      result_id: "deck_viewer_#{code}",
      link: Routes.live_path(BackendWeb.Endpoint, DeckviewerLive, %{"code" => code})
    }
  end
end
