defmodule BackendWeb.DeckcodeSearchProvider do
  @moduledoc false
  @behaviour OmniBar.SearchProvider
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone
  alias OmniBar.Result
  alias BackendWeb.Router.Helpers, as: Routes
  alias BackendWeb.DeckviewerLive
  alias BackendWeb.DeckLive
  alias Backend.Streaming.StreamingNow

  def search(term, callback) do
    case Deck.decode(term) do
      {:ok, deck} -> handle_valid_deck(deck, term, callback)
      _ -> nil
    end
  end

  defp handle_valid_deck(deck, term, callback) do
    with false <- deck_result(deck, term) |> callback.(),
         false <- deckviewer_result(deck, term) |> callback.(),
         false <- streaming_now_result(deck, term, callback),
         d = %{id: _deck_id} <- Hearthstone.deck(deck) do
      streamer_decks_result(d, term) |> callback.()
    end
  end

  def streaming_now_result(deck, term, callback) do
    code = Deck.deckcode(deck)

    currently_streaming =
      StreamingNow.streaming_now()
      |> Enum.count(&Deck.equals?(deck, &1.deckcode))

    if currently_streaming > 0 do
      %Result{
        search_term: term,
        display_value: "Live on #{currently_streaming} streams",
        priority: 0.4,
        result_id: "streaming_now_deck_result",
        link:
          Routes.live_path(BackendWeb.Endpoint, BackendWeb.StreamingNowLive, %{"deckcode" => code})
      }
      |> callback.()
    else
      false
    end
  end

  def streamer_decks_result(d, term) do
    %Result{
      search_term: term,
      display_value: "Find streamer decks for this deck",
      priority: 0.7,
      result_id: "streamer_decks_deck_result",
      link: Routes.streaming_path(BackendWeb.Endpoint, :streamer_decks, %{"deck_id" => d.id})
    }
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

  def deck_result(deck, term) do
    id_or_code =
      case deck do
        %{id: id} when not is_nil(id) -> id
        _ -> Deck.deckcode(deck)
      end

    %Result{
      search_term: term,
      display_value: "View deck and stats",
      priority: 2,
      result_id: "deck_id_#{id_or_code}",
      link: Routes.live_path(BackendWeb.Endpoint, DeckLive, [id_or_code])
    }
  end
end
