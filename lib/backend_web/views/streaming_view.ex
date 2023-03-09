defmodule BackendWeb.StreamingView do
  use BackendWeb, :view
  alias Backend.Hearthstone.Deck
  alias Backend.Streaming.Streamer
  alias Backend.Streaming.StreamerDeck
  alias Hearthstone.Enums.Format
  alias BackendWeb.ViewUtil

  def twitch_link(streamer) do
    twitch_link(Streamer.twitch_login(streamer), Streamer.twitch_display(streamer))
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

  def create_streamer_list(conn, streamers) do
    ~E"""
          <option data-link="<%= remove_from_link(conn, ["twitch_id", "twitch_login"]) %>" value="All Streamers">
          <%= for s <- streamers do %>
            <option data-link="<%= update_link(conn, "twitch_id", s.twitch_id) %>" value="<%= Streamer.twitch_display(s) %>">
              <%= Streamer.twitch_login(s) %>
            </option>
          <% end %>
    """
  end

  def filter_archetypes(sd, []), do: sd

  def filter_archetypes(sd, archetypes) do
    sd
    |> Enum.filter(fn %{archetype: a} -> a && a.id in archetypes end)
  end

  def deck_toggle_link(conn, %{deck: %{id: id}}) do
    with deck_id <- conn.query_params["deck_id"],
         true <- to_string(id) == deck_id do
      remove_from_link(conn, "deck_id")
    else
      _ ->
        new_params =
          conn.query_params
          |> Map.drop(["twitch_login", "twitch_id"])
          |> Map.put("deck_id", id)

        Routes.streaming_path(conn, :streamer_decks, new_params)
    end
  end

  def deck_toggle_link(_), do: nil

  defp legend_rank(0), do: nil
  defp legend_rank(lr), do: lr

  defp get_archetype(%{hsreplay_archetype: archetype_id}) when not is_nil(archetype_id),
    do: Backend.HSReplay.get_archetype(archetype_id)

  defp get_archetype(deck), do: Backend.HSReplay.guess_archetype(deck)

  defp amount_played(%{wins: wins, losses: losses}) when wins + losses > 0,
    do: "#{wins + losses} game(s)"

  defp amount_played(%{minutes_played: minutes}), do: "#{minutes} min"

  def render("streamer_decks.html", %{
        streamer_decks: streamer_decks,
        conn: conn,
        streamers: streamers,
        archetypes: archetypes_raw,
        include_cards: include,
        exclude_cards: exclude,
        criteria: %{"offset" => offset, "limit" => limit}
      }) do
    title = "Streamer Decks"
    {prev_offset, next_offset} = get_surrounding(offset, limit)
    archetypes = archetypes_raw || []

    rows =
      streamer_decks
      |> Enum.map(fn sd ->
        %{
          streamer: streamer_link(sd.streamer, conn),
          class: sd.deck.class |> Deck.class_name(),
          code: deckcode(sd.deck),
          deck_link: deck_toggle_link(conn, sd),
          last_played: sd.last_played,
          format: sd.deck.format |> Format.name(Format.standard()),
          best_legend_rank: legend_rank(sd.best_legend_rank),
          worst_legend_rank: legend_rank(sd.worst_legend_rank),
          latest_legend_rank: legend_rank(sd.latest_legend_rank),
          win_loss: win_loss(sd),
          amount_played: amount_played(sd),
          archetype: get_archetype(sd.deck),
          links: links(sd)
        }
      end)
      |> filter_archetypes(archetypes)

    update_link = fn new_params ->
      Routes.streaming_path(conn, :streamer_decks, conn.query_params |> Map.merge(new_params))
    end

    %{
      prev_button: prev_button,
      next_button: next_button,
      dropdown: limit_dropdown
    } =
      ViewUtil.handle_pagination(conn.query_params, update_link,
        default_limit: 20,
        limit_options: [5, 10, 20, 30, 40, 50]
      )

    dropdowns = [
      limit_dropdown,
      create_legend_dropdown(conn, "legend", "Peak"),
      # create_legend_dropdown(conn, "latest_legend_rank", "Latest"),
      # create_legend_dropdown(conn, "worst_legend_rank", "Worst"),
      create_format_dropdown(conn),
      create_class_dropdown(conn),
      # create_min_minutes_played_dropdown(conn),
      create_lk_dropdown(conn),
      create_last_played_dropdown(conn)
      # keep below last :shrug:
      # create_show_archetypes_dropdown(conn)
    ]

    include_options = card_options(include)
    exclude_options = card_options(exclude)

    render("streamer_decks.html", %{
      rows: rows,
      title: title,
      dropdowns: dropdowns,
      streamer_list: create_streamer_list(conn, streamers),
      prev_button: prev_button,
      show_archetype: true,
      conn: conn,
      include_options: include_options,
      exclude_options: exclude_options,
      next_button: next_button
    })
  end

  def card_options(selected) do
    Backend.HearthstoneJson.playable_cards()
    |> Enum.map(fn c ->
      %{
        selected: c.dbf_id in selected,
        value: c.dbf_id,
        name: c.name,
        display: c.name
      }
    end)
  end

  def win_loss(sd = %{wins: w, losses: l}) do
    winrate = StreamerDeck.winrate(sd)

    style =
      if w + l > 5 do
        Components.WinrateTag.winrate_style(winrate)
      else
        ""
      end

    if winrate do
      ~E"""
      <div class="tag" style="<%= style %>"><%="#{w} - #{l}"%></div>
      """
    else
      ""
    end
  end

  def links(sd) do
    deck = deckcode_links(deckcode(sd.deck))
    twitch = twitch_link(sd.streamer |> Streamer.twitch_login(), "twitch", ["tag", "is-link"])

    ~E"""
    <%= deck %>
    <%= twitch %>
    """
  end

  def create_lk_dropdown(conn) do
    curr = with nil <- conn.query_params["lich_king"], do: "no"

    options =
      [{"yes", "Includes New Cards"}, {"no", "Any decks"}]
      |> Enum.map(fn {val, display} ->
        %{
          link: update_link(conn, "lich_king", val),
          selected: val == curr,
          display: display
        }
      end)

    {options, "New Cards"}
  end

  def create_min_minutes_played_dropdown(conn) do
    options =
      [0, 30, 60, 90, 120, 180, 240, 300, 360, 480, 600]
      |> Enum.map(fn mmp ->
        %{
          link: update_link(conn, "min_minutes_played", mmp),
          selected: to_string(mmp) == conn.query_params["min_minutes_played"],
          display: ">= #{mmp} min"
        }
      end)

    title = ~E"""
    <span class="icon">
      <i class="fas fa-hourglass"></i>
    </span>
    """

    {options, title}
  end

  def create_show_archetypes_dropdown(conn) do
    options =
      ["yes", "no"]
      |> Enum.map(fn sa ->
        %{
          link: update_link(conn, "show_archetypes", sa),
          selected: to_string(sa) == conn.query_params["show_archetypes"],
          display: sa |> Recase.to_title()
        }
      end)

    {options, "Show Archetypes"}
  end

  def create_last_played_dropdown(conn) do
    last_played = Map.get(conn.query_params, "last_played")

    options =
      [
        {"Last hour", "min_ago_60"},
        {"Last day", "min_ago_1440"},
        {"Last 3 days", "min_ago_4320"},
        {"Last 7 days", "min_ago_10080"},
        {"Last 15 days", "min_ago_21600"},
        {"Last 30 days", "min_ago_43200"},
        {"Last 120 days", "min_ago_172800"}
      ]
      |> Enum.map(fn {display, lp} ->
        %{
          link: update_link(conn, "last_played", lp),
          selected: last_played == to_string(lp),
          display: display
        }
      end)

    {[nil_option(conn, "last_played") | options], "Last Played"}
  end

  def create_class_dropdown(conn) do
    options =
      [
        "DEATHKNIGHT",
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

  def create_legend_dropdown(conn, query_param, title) do
    options =
      [100, 200, 500, 1000, 5000]
      |> Enum.map(fn lr ->
        %{
          link: update_link(conn, query_param, lr),
          selected: to_string(Map.get(conn.query_params, query_param)) == to_string(lr),
          display: "Top #{lr}"
        }
      end)

    {[nil_option(conn, query_param) | options], title}
  end

  def update_link(conn, param, value, reset_offset \\ true) do
    new_params =
      if(reset_offset, do: Map.delete(conn.query_params, "offset"), else: conn.query_params)
      |> Map.put(param, value)

    Routes.streaming_path(conn, :streamer_decks, new_params)
  end

  def create_format_dropdown(conn) do
    options =
      Format.all()
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

  def remove_from_link(conn, param) when is_binary(param), do: remove_from_link(conn, [param])

  def remove_from_link(conn, params) do
    Routes.streaming_path(conn, :streamer_decks, Map.drop(conn.query_params, params))
  end

  def deckcode_links(<<deckcode::binary>>) do
    hsreplay = Backend.HSReplay.create_deck_link(deckcode)

    ~E"""
    <a class="is-link tag" href="<%= hsreplay %>">HSReplay</a>
    """
  end

  def deckcode(deck), do: Backend.Hearthstone.Deck.deckcode(deck.cards, deck.hero, deck.format)

  def streamer_link(streamer, conn) do
    twitch_id = streamer.twitch_id |> to_string()
    tl = streamer |> Streamer.twitch_login()
    td = streamer |> Streamer.twitch_display()

    link =
      case {Map.get(conn.query_params, "twitch_id"), Map.get(conn.query_params, "twitch_login")} do
        {^twitch_id, _} ->
          remove_from_link(conn, ["twitch_id", "twitch_login", "offset"])

        {_, ^tl} ->
          remove_from_link(conn, ["twitch_id", "twitch_login", "offset"])

        _ ->
          new_params =
            conn.query_params
            |> Map.drop(["deck_id", "twitch_login", "offset"])
            |> Map.put("twitch_id", twitch_id)

          Routes.streaming_path(conn, :streamer_decks, new_params)
      end

    ~E"""
      <a class="is-link" href="<%= link %>"><%= td %></a>
    """
  end
end
