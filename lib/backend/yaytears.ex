defmodule Backend.Yaytears do
  @moduledoc false
  def create_deckstrings_link(tournament_id, battletag_full) do
    "https://www.yaytears.com/battlefy/#{tournament_id}/#{battletag_full |> URI.encode_www_form()}"
  end
end
