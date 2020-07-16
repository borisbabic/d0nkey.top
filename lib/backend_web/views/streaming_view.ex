defmodule BackendWeb.StreamingView do
  use BackendWeb, :view

  def named_twitch_link(streamer) do
    twitch_link = twitch_link(streamer)

    ~E"""
      <a class="is-link" href="<%= twitch_link %>"><%= streamer.twitch_display %></a>
    """
  end

  def render("streamer_decks.html", %{streamer_decks: streamer_decks, conn: conn}) do
    title = "Streamer Decks"
    headers = ["Streamer", "Class", "Code", "Last Played", "Mode", "Legend Peak"]

    rows =
      streamer_decks
      |> Enum.map(fn sd ->
        {
          internal_link(sd.streamer, conn),
          sd.deck.hero |> Backend.HearthstoneJson.get_class() |> Recase.to_title(),
          sd.deck.deckcode,
          sd.last_played,
          if(sd.deck.format == 1, do: "Wild", else: "Standard"),
          if(sd.best_legend_rank > 0, do: sd.best_legend_rank, else: nil)
        }
      end)

    render("streamer_decks.html", %{rows: rows, headers: headers, title: title})
  end

  def render("streamers_decks.html", %{decks: decks}) do
    title = (decks |> Enum.at(0)).streamer |> named_twitch_link()
    headers = ["Class", "Code", "Last Played", "Mode", "Legend Peak"]

    rows =
      decks
      |> Enum.map(fn sd ->
        {
          sd.deck.hero |> Backend.HearthstoneJson.get_class() |> Recase.to_title(),
          sd.deck.deckcode,
          sd.last_played,
          if(sd.deck.format == 1, do: "Wild", else: "Standard"),
          if(sd.best_legend_rank > 0, do: sd.best_legend_rank, else: nil)
        }
      end)

    render("streamers_decks.html", %{rows: rows, title: title, headers: headers})
  end

  def internal_link(%{twitch_login: tl, twitch_display: td}, conn) do
    link = Routes.streaming_path(conn, :streamers_decks, tl)

    ~E"""
      <a class="is-link" href="<%= link %>"><%= td %></a>
    """
  end

  def twitch_link(%{twitch_login: twitch_login}), do: "https://www.twitch.tv/#{twitch_login}"
end
