defmodule Backend.GeekLounge do
  @moduledoc "hearthstone.geeklounge.com"
  alias GeekLounge.Hearthstone.Tournament
  alias GeekLounge.Hearthstone.Api
  @tournament_source "geeklounge"

  def fetch_tournament(tournament_url_or_id) do
    tournament_url_or_id
    |> id()
    |> Api.fetch_tournament()
  end

  def save_tournament_lineups(tournament_url_or_id) when is_binary(tournament_url_or_id) do
    with {:ok, tournament} <- fetch_tournament(tournament_url_or_id) do
      save_tournament_lineups(tournament)
    end
  end

  def save_tournament_lineups(%Tournament{} = tournament) do
    tournament_id = tournament.id
    player_ids = Enum.map(tournament.participants, & &1.player.id)

    for player_id <- player_ids,
        {:ok, participant} <- [Api.fetch_participant(tournament_id, player_id)],
        deck_strings = Enum.map(participant.decks, & &1.deck_string),
        Enum.any?(deck_strings) do
      name = participant.player.battletag || player_id

      Backend.Hearthstone.get_or_create_lineup(
        tournament.id,
        @tournament_source,
        name,
        deck_strings
      )
    end
  end

  def id(%Tournament{id: id}), do: id

  def id(tournament_url_or_id) when is_binary(tournament_url_or_id) do
    case extract_id(tournament_url_or_id) do
      {:ok, id} -> id
      _ -> tournament_url_or_id
    end
  end

  def extract_id(tournament_url) do
    uri = URI.parse(tournament_url)

    case String.split(uri.path || "", "/") do
      ["", "tournaments", tournament_id | _] -> {:ok, tournament_id}
      ["", "api", "v1", "tournaments", tournament_id | _] -> {:ok, tournament_id}
      _ -> {:error, :cant_extract_id_from_url}
    end
  end
end
