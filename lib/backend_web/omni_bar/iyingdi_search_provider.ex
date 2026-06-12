defmodule BackendWeb.IyingdiSearchProvider do
  @moduledoc false
  @behaviour OmniBar.SearchProvider
  alias OmniBar.Result
  alias BackendWeb.Router.Helpers, as: Routes
  alias Backend.Iyingdi

  def search(term, callback) do
    with true <- term =~ "iyingdi.com",
         set_id when is_binary(set_id) <- Iyingdi.extract_set_id_from_url(term) do
      %Result{
        search_term: term,
        display_value: "View lineups",
        priority: 888,
        result_id: "iyingdi_view_import_lineups",
        link: Routes.iyingdi_path(BackendWeb.Endpoint, :lineups, set_id)
      }
      |> callback.()
    end
  end
end
