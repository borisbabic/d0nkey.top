defmodule BackendWeb.HearthstoneController do
  use BackendWeb, :controller
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck

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

  def export_lineups(conn, %{"tournament_source" => _tournament_source, "tournament_id" => _tournament_id} = params) do
    {opts, criteria} = Map.split(params, ["deck_format"])

    response =
      Hearthstone.lineups(criteria)
      |> Enum.map(fn
        lineup ->
          [lineup.name | deck_part(lineup.decks, opts)]
      end)
      |> CSV.encode()
      |> Enum.join()

    conn
    |> put_status(200)
    |> csv(response)
  end

  defp deck_part(decks, opts) do
    formatter =
      case Map.get(opts, "deck_format") do
        "link" -> &Deck.link/1
        _ -> &Deck.deckcode/1
      end

    Enum.map(decks, formatter)
  end
end
