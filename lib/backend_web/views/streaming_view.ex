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
          sd.deck.class |> class_name(),
          deckcode(sd.deck),
          sd.last_played,
          if(sd.deck.format == 1, do: "Wild", else: "Standard"),
          if(sd.best_legend_rank > 0, do: sd.best_legend_rank, else: nil),
          links(sd)
        }
      end)

    dropdowns = [
      create_legend_dropdown(conn),
      create_format_dropdown(conn),
      create_class_dropdown(conn)
    ]

    render("streamer_decks.html", %{rows: rows, title: title, dropdowns: dropdowns})
  end

  def links(sd) do
    deck = deckcode_links(deckcode(sd.deck))
    twitch = twitch_link(sd.streamer.twitch_login, "twitch", ["tag", "is-link"])

    ~E"""
    <%= deck %>
    <%= twitch %>
    """
  end

  def class_name("DEMONHUNTER"), do: "Demon Hunter"
  def class_name(c), do: c |> Recase.to_title()

  def create_class_dropdown(conn) do
    options =
      [
        "DEMONHUNTER",
        "DRUID",
        "HUNTER",
        "MAGE",
        "PALADIN",
        "PRIEST",
        "ROGUE",
        "SHAMAN",
        "WARLOCK",
        "WARRIOR"
      ]
      |> Enum.map(fn c ->
        %{
          link:
            Routes.streaming_path(conn, :streamer_decks, Map.put(conn.query_params, "class", c)),
          selected: to_string(Map.get(conn.query_params, "class")) == to_string(c),
          display: class_name(c)
        }
      end)

    {[any_option(conn, "class") | options], dropdown_title(options, "Class")}
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

    {[any_option(conn, "legend") | options], dropdown_title(options, "Legend Peak")}
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

    {[any_option(conn, "format") | options], dropdown_title(options, "Format")}
  end

  def any_option(conn, query_param, display \\ "Any") do
    %{
      link:
        Routes.streaming_path(conn, :streamer_decks, Map.delete(conn.query_params, query_param)),
      selected: Map.get(conn.query_params, query_param) == nil,
      display: display
    }
  end

  def deckcode_links(<<deckcode::binary>>) do
    hsreplay = Backend.HSReplay.create_deck_link(deckcode)
    hsdeckviewer = Backend.HSDeckViewer.create_link(deckcode)

    ~E"""
    <a class="is-link tag" href="<%= hsreplay %>">HSReplay</a>
    <a class="is-link tag" href="<%= hsdeckviewer %>">HSDeckViewer</a>
    """
  end

  def deckcode(deck), do: Backend.Hearthstone.Deck.deckcode(deck.cards, deck.hero, deck.format)

  def streamer_link(%{twitch_login: tl, twitch_display: td}, conn) do
    link =
      case Map.get(conn.query_params, "twitch_login") do
        ^tl ->
          Routes.streaming_path(
            conn,
            :streamer_decks,
            Map.delete(conn.query_params, "twitch_login")
          )

        _ ->
          Routes.streaming_path(
            conn,
            :streamer_decks,
            Map.put(conn.query_params, "twitch_login", tl)
          )
      end

    ~E"""
      <a class="is-link" href="<%= link %>"><%= td %></a>
    """
  end
end
