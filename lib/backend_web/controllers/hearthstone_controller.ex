defmodule BackendWeb.HearthstoneController do
  use BackendWeb, :controller
  def patch_notes(conn, _params) do
    url = case Backend.LatestHSArticles.patch_notes_url() do
      nil -> "https://playhearthstone.com/news/patchnotes#articles"
      url -> url
    end
    redirect(conn, external: url)
  end
end
