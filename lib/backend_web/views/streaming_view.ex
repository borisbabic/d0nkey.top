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
          streamer_link(sd.streamer, conn),
          sd.deck.hero |> Backend.HearthstoneJson.get_class() |> Recase.to_title(),
          deckcode(sd.deck),
          sd.last_played,
          if(sd.deck.format == 1, do: "Wild", else: "Standard"),
          if(sd.best_legend_rank > 0, do: sd.best_legend_rank, else: nil),
          deckcode_links(deckcode(sd.deck))
        }
      end)

    dropdowns = [
      create_legend_dropdown(conn),
      create_format_dropdown(conn)
      #      create_class_dropdown(conn),
    ]

    render("streamer_decks.html", %{rows: rows, title: title, dropdowns: dropdowns})
  end

  def create_legend_dropdown(conn) do
    options =
      [100, 500, 1000, 5000]
      |> Enum.map(fn lr ->
        %{
          link:
            Routes.streaming_path(conn, :streamer_decks, Map.put(conn.query_params, "legend", lr)),
          selected: to_string(Map.get(conn.query_params, "legend")) == to_string(lr),
          display: "Top #{lr}"
        }
      end)

    {options, title(options, "Legend Peak")}
  end

  def create_format_dropdown(conn) do
    options =
      [{1, "Wild"}, {2, "Standard"}]
      |> Enum.map(fn {f, display} ->
        %{
          link:
            Routes.streaming_path(conn, :streamer_decks, Map.put(conn.query_params, "format", f)),
          selected: to_string(Map.get(conn.query_params, "format")) == to_string(f),
          display: display
        }
      end)

    {options, title(options, "Format")}
  end

  def deckcode_links(<<deckcode::binary>>) do
    hsreplay = Backend.HSReplay.create_deck_link(deckcode)
    hsdeckviewer = Backend.HSDeckViewer.create_link(deckcode)

    ~E"""
    <a class="is-link tag" href="<%= hsreplay %>">HSReplay</a>
    <a class="is-link tag" href="<%= hsdeckviewer %>">HSDeckViewer</a>
    """
  end

  def title(options, <<default::binary>>) do
    selected_title =
      options
      |> Enum.find_value(fn o -> o.selected && o.display end)

    selected_title || default
  end

  def deckcode(deck), do: Backend.Hearthstone.Deck.deckcode(deck.cards, deck.hero, deck.format)

  def streamer_link(%{twitch_login: tl, twitch_display: td}, conn) do
    link =
      Routes.streaming_path(conn, :streamer_decks, Map.put(conn.query_params, "twitch_login", tl))

    ~E"""
      <a class="is-link" href="<%= link %>"><%= td %></a>
    """
  end
end
