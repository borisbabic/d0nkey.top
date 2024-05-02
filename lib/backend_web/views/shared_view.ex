defmodule BackendWeb.SharedView do
  use BackendWeb, :view

  def render("datetime.html", %{datetime: maybe_naive}) do
    # always succeeds for Etc/UTC, see h DateTime.from_naive
    {:ok, not_naive} = DateTime.from_naive(maybe_naive, "Etc/UTC")
    timestamp_ms = DateTime.to_unix(not_naive, :millisecond)
    id = :crypto.strong_rand_bytes(42) |> Base.encode64() |> binary_part(0, 42)
    human_readable = Util.datetime_to_presentable_string(maybe_naive)
    render("datetime.html", %{id: id, human_readable: human_readable, timestamp_ms: timestamp_ms})
  end

  def render("legend_rank.html", %{rank: rank}),
    do: ~E(<span class="tag legend-rank"><%= rank %></span>)

  def render("game_type.html", %{type: type}) do
    name =
      type
      |> Hearthstone.Enums.BnetGameType.game_type_name()

    color =
      name
      |> css_color()

    ~E"""
    <span class="tag" style="background-color: <%= color %>;">
      <%= name %>
    </span>
    """
  end

  def render("empty.html", _) do
    ~E"""

    """
  end

  def render("player_icon.html", %{name: name}) do
    name
    |> Backend.PlayerIconBag.get()
    |> case do
      {:unicode, icon} ->
        ~E"""
          <span class="icon small"><%= icon %></span>
        """

      {:unicode, icon, link} ->
        ~E"""
          <span class="icon small">
            <object>
              <a href="<%= link %>" target="_blank">
                <%= icon %>
              </a>
            </object>
          </span>
        """

      {:image, path} ->
        ~E"""
          <span class="icon small"><img src="<%= path %>" alt="<%= name %>"></span>
        """

      {:image, path, link} ->
        ~E"""
          <span class="icon small">
            <object>
              <a href="<%= link %>" target="_blank">
                <img src="<%= path %>" alt="<%= name %>">
              </a>
            </object>
          </span>
        """

      _ ->
        ~E"""
        """
    end
  end

  def render("player_name.html", p = %{name: name}) do
    icon_part = render_player_icon(name)
    country = Map.get(p, :country)
    preferences = Backend.PlayerCountryPreferenceBag.get(name, country)

    ~E"""
      <%= if country do%>
        <%= country_flag(country, preferences) %>
      <% end %>
      <span><%= icon_part %><%= name %></span>
    """
  end

  def render("player_link.html", assigns) do
    ~E"""
      <a href="<%= @link %>">
          <%= render_player_name(@name, assigns.with_country) %>
      </a>
    """
  end

  defp css_color(name) do
    normalized =
      name
      |> String.replace(" ", "")
      |> String.downcase()

    "var(--color-#{normalized})"
  end
end
