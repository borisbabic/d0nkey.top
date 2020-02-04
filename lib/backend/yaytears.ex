defmodule Backend.Yaytears do
  def create_deckstrings_link(battlefy_id, battletag_full) do
    "https://www.yaytears.com/battlefy/#{battlefy_id}/#{battletag_full |> URI.encode_www_form()}"
  end
end
