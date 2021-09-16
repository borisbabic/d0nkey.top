defmodule BackendWeb.BattletagSearchProvider do
  @behaviour OmniBar.SearchProvider
  alias OmniBar.Result
  alias BackendWeb.Router.Helpers, as: Routes
  alias Backend.Blizzard

  def search(term, callback) do
    trimmed = String.trim(term)

    if Blizzard.is_battletag?(trimmed) do
      %Result{
        search_term: term,
        display_value: "View #{trimmed} player profile",
        priority: 1,
        result_id: "battletag_player_profile_result",
        link: Routes.player_path(BackendWeb.Endpoint, :player_profile, trimmed)
      }
      |> callback.()
    end
  end
end
