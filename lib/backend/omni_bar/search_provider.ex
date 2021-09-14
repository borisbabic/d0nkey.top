defmodule OmniBar.SearchProvider do
  @moduledoc "Search providers will handle the variety of different things to search for"
  alias OmniBar.Result
  @type result_callback :: (Result.t() | [Result.t()] -> boolean)

  @doc """
  Instructs a provider to start a search for the term
  If the result callback returns true the search provider should halt further searches for the term
  """
  @callback search(String.t(), result_callback) :: any()
end
