defmodule BackendWeb.HearthstoneController do
  use BackendWeb, :controller

  def patch_notes(conn, _params) do
    url =
      case Backend.LatestHSArticles.patch_notes_url() do
        nil -> "https://hearthstone.blizzard.com/news/patchnotes#articles"
        url -> url
      end

    redirect(conn, external: url)
  end

  def article(conn, %{"blog_id" => "23790401"}) do
    conn
    |> put_view(BackendWeb.PageView)
    |> render("rick_roll.html", %{})
  end

  def article(conn, %{"blog_id" => blog_id}) do
    url = "https://hearthstone.blizzard.com/blog/#{blog_id}"
    redirect(conn, external: url)
  end
end
