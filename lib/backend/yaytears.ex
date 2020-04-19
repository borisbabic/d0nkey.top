defmodule Backend.Yaytears do
  @moduledoc false
  @spec create_deckstrings_link(Backend.Battlefy.tournament_id(), Backend.Battlefy.battletag()) ::
          String.t()
  def create_deckstrings_link(tournament_id, battletag_full) do
    "https://www.yaytears.com/battlefy/#{tournament_id}/#{battletag_full |> URI.encode_www_form()}"
  end
end
