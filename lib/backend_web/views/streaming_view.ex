defmodule BackendWeb.StreamingView do
  use BackendWeb, :view

  def twitch_link(streamer) do
    twitch_link(streamer.twitch_login, streamer.twitch_display)
  end

  def twitch_link(login, display, classes \\ ["is-link"]) do
    twitch_link = Backend.Twitch.create_channel_link(login)
    class = Enum.join(classes, " ")

    ~E"""
      <a class="<%= class %>" href="<%= twitch_link %>"><%= display %></a>
    """
  end

  def render("streamer_decks.html", %{streamer_decks: streamer_decks, conn: conn}) do
    title = "Streamer Decks"

    rows =
      streamer_decks
      |> Enum.map(fn sd ->
        {
          internal_link(sd.streamer, conn),
          sd.deck.hero |> Backend.HearthstoneJson.get_class() |> Recase.to_title(),
          sd.deck.deckcode,
          sd.last_played,
          if(sd.deck.format == 1, do: "Wild", else: "Standard"),
          if(sd.best_legend_rank > 0, do: sd.best_legend_rank, else: nil),
          ~E"""
          <%= hsreplay_link(sd.deck.deckcode) %>
          """
        }
      end)

    render("streamer_decks.html", %{rows: rows, title: title})
  end

  def hsreplay_link(<<deckcode::binary>>) do
    link = Backend.HSReplay.create_deck_link(deckcode)

    ~E"""
    <a class="is-link tag" href="<%= link %>">HSReplay</a>
    """
  end

  def render("streamers_decks.html", %{decks: decks}) do
    title = (decks |> Enum.at(0)).streamer |> twitch_link()

    rows =
      decks
      |> Enum.map(fn sd ->
        {
          sd.deck.hero |> Backend.HearthstoneJson.get_class() |> Recase.to_title(),
          sd.deck.deckcode,
          sd.last_played,
          if(sd.deck.format == 1, do: "Wild", else: "Standard"),
          if(sd.best_legend_rank > 0, do: sd.best_legend_rank, else: nil),
          hsreplay_link(sd.deck.deckcode)
        }
      end)

    render("streamers_decks.html", %{rows: rows, title: title})
  end

  def internal_link(%{twitch_login: tl, twitch_display: td}, conn) do
    link = Routes.streaming_path(conn, :streamers_decks, tl)

    ~E"""
      <a class="is-link" href="<%= link %>"><%= td %></a>
    """
  end
end