defmodule GeekLounge.Hearthstone.Api do
  @moduledoc "Api for hearthstone.geeklounge.com"

  alias GeekLounge.Hearthstone.Tournament
  alias GeekLounge.Hearthstone.Participant
  alias GeekLounge.Hearthstone.Deck

  def fetch_tournament(tournament_id) do
    url = tournament_url(tournament_id)

    with {:ok, %{body: body}} <- get(url),
         {:ok, decoded} <- JSON.decode(body) do
      {:ok, Tournament.from_raw_map(decoded)}
    end
  end

  def fetch_participant(tournament_id, player) do
    url = participant_url(tournament_id, player)

    with {:ok, %{body: body}} <- get(url),
         {:ok, decoded} <- JSON.decode(body) do
      {:ok, Participant.from_raw_map(decoded)}
    end
  end

  defp tournament_url(tournament_id) do
    "/api/v1/tournaments/#{tournament_id}"
  end

  def participant_url(tournament_id, player) do
    "/api/v1/tournaments/#{tournament_id}/participants/#{player}"
  end

  def fetch_deck(deck_id) do
    url = deck_url(deck_id)

    with {:ok, %{body: body}} <- get(url),
         {:ok, decoded} <- JSON.decode(body) do
      {:ok, Deck.from_raw_map(decoded)}
    end
  end

  def deck_url(deck_id) do
    "/api/v1/decks/#{deck_id}"
  end

  def client() do
    Tesla.client([{Tesla.Middleware.BaseUrl, "https://hearthstone.geeklounge.com/"}])
  end

  def get(url) do
    Tesla.get(client(), url)
  end
end
