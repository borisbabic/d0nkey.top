defmodule BackendWeb.StreamingView do
  use BackendWeb, :view
  alias Backend.Hearthstone.Deck

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

  def get_surrounding(%{"offset" => offset, "limit" => limit}), do: get_surrounding(offset, limit)

  def get_surrounding(offset, limit) when is_integer(offset) and is_integer(limit),
    do: {(offset - limit) |> max(0), offset + limit}

  def get_surrounding(offset, limit),
    do: get_surrounding(Util.to_int_or_orig(offset), Util.to_int_or_orig(limit))

  def prev_button(_, prev_offset, offset) when prev_offset == offset do
    ~E"""
    <span class="icon button is-link">
        <i class="fas fa-caret-left"></i>
    </span>
    """
  end

  def prev_button(conn, prev_offset, _) do
    link = update_link(conn, "offset", prev_offset, false)

    ~E"""
    <a class="icon button is-link" href="<%= link %>">
      <i class="fas fa-caret-left"></i>
    </a>
    """
  end

  def next_button(conn, next_offset) do
    link = update_link(conn, "offset", next_offset, false)

    ~E"""
    <a class="icon button is-link" href="<%= link %>">
      <i class="fas fa-caret-right"></i>
    </a>
    """
  end

  def create_streamer_list(conn, streamers) do
    ~E"""
          <option data-link="<%= remove_from_link(conn, "twitch_login") %>" value="All Streamers">
          <%= for %{twitch_display: d, twitch_login: l} <- streamers do %>
            <option data-link="<%= update_link(conn, "twitch_login", l) %>" value="<%= d %>">
          <% end %>
    """
  end

  def render("streamer_decks.html", %{
        streamer_decks: streamer_decks,
        conn: conn,
        streamers: streamers,
        criteria: %{"offset" => offset, "limit" => limit}
      }) do
    title = "Streamer Decks"
    {prev_offset, next_offset} = get_surrounding(offset, limit)

    rows =
      streamer_decks
      |> Enum.map(fn sd ->
        %{
          streamer: streamer_link(sd.streamer, conn),
          class: sd.deck.class |> Deck.class_name(),
          code: deckcode(sd.deck),
          last_played: sd.last_played,
          format: if(sd.deck.format == 1, do: "Wild", else: "Standard"),
          best_legend_rank: if(sd.best_legend_rank > 0, do: sd.best_legend_rank, else: nil),
          archetype: Backend.HSReplay.guess_archetype(sd.deck),
          links: links(sd)
        }
      end)

    dropdowns = [
      create_limit_dropdown(conn, limit),
      create_legend_dropdown(conn),
      create_format_dropdown(conn),
      create_class_dropdown(conn)
    ]

    render("streamer_decks.html", %{
      rows: rows,
      title: title,
      dropdowns: dropdowns,
      streamer_list: create_streamer_list(conn, streamers),
      prev_button: prev_button(conn, prev_offset, offset),
      show_archetype: conn.query_params["show_archetypes"] == "yes",
      next_button: next_button(conn, next_offset)
    })
  end

  def links(sd) do
    deck = deckcode_links(deckcode(sd.deck))
    twitch = twitch_link(sd.streamer.twitch_login, "twitch", ["tag", "is-link"])

    ~E"""
    <%= deck %>
    <%= twitch %>
    """
  end

  def create_limit_dropdown(conn, limit) do
    options =
      [
        10,
        20,
        30,
        50,
        75,
        100,
        250,
        500
      ]
      |> Enum.map(fn l ->
        %{
          link:
            Routes.streaming_path(conn, :streamer_decks, Map.put(conn.query_params, "limit", l)),
          selected: to_string(limit) == to_string(l),
          display: "Show #{l} decks"
        }
      end)

    {options, dropdown_title(options, "Page Size")}
  end

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
          display: Deck.class_name(c)
        }
      end)

    {[nil_option(conn, "class") | options], dropdown_title(options, "Class")}
  end

  def create_legend_dropdown(conn) do
    options =
      [100, 500, 1000, 5000]
      |> Enum.map(fn lr ->
        %{
          link: update_link(conn, "legend", lr),
          selected: to_string(Map.get(conn.query_params, "legend")) == to_string(lr),
          display: "Top #{lr}"
        }
      end)

    {[nil_option(conn, "legend") | options], dropdown_title(options, "Legend Peak")}
  end

  def update_link(conn, param, value, reset_offset \\ true) do
    new_params =
      if(reset_offset, do: Map.delete(conn.query_params, "offset"), else: conn.query_params)
      |> Map.put(param, value)

    Routes.streaming_path(conn, :streamer_decks, new_params)
  end

  def create_format_dropdown(conn) do
    options =
      [{1, "Wild"}, {2, "Standard"}]
      |> Enum.map(fn {f, display} ->
        %{
          link: update_link(conn, "format", f),
          selected: to_string(Map.get(conn.query_params, "format")) == to_string(f),
          display: display
        }
      end)

    {[nil_option(conn, "format") | options], dropdown_title(options, "Format")}
  end

  def nil_option(conn, query_param, display \\ "Any") do
    %{
      link: remove_from_link(conn, query_param),
      selected: Map.get(conn.query_params, query_param) == nil,
      display: display
    }
  end

  def remove_from_link(conn, param) do
    Routes.streaming_path(conn, :streamer_decks, Map.delete(conn.query_params, param))
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
          remove_from_link(conn, "twitch_login")

        _ ->
          update_link(conn, "twitch_login", tl)
      end

    ~E"""
      <a class="is-link" href="<%= link %>"><%= td %></a>
    """
  end
end
