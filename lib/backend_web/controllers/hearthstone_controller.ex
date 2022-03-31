defmodule BackendWeb.HearthstoneController do
  use BackendWeb, :controller
  def patch_notes(conn, _params) do
    url = case Backend.LatestHSArticles.patch_notes_url() do
      nil -> "https://playhearthstone.com/news/patchnotes#articles"
      url -> url
    end
    redirect(conn, external: url)
  end

  def article(conn, %{"blog_id" => "23790401"}) do
    conn
    |> put_status(302)
    |> redirect(external: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
  end
  def article(conn, %{"blog_id" => blog_id}) do
    url = "https://playhearthstone.com/blog/#{blog_id}"
    redirect(conn, external: url)
  end
end
