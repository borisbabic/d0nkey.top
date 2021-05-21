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

  defp css_color(name) do
    normalized =
      name
      |> String.replace(" ", "")
      |> String.downcase()

    "var(--color-#{normalized})"
  end

  def render("empty.html", _) do
    ~E"""

    """
  end

  def render("player_icon.html", %{name: name}) do
    picture =
      cond do
        name in ["D0nkey", "D0nkey#2470"] -> "/favicon.ico"
        name in ["Carvalho", "Carvalho#1712"] -> "/images/icons/carvalho.png"
        name in ["Blastoise", "Blastoise#1855"] -> "/images/icons/blastoise.png"
        true -> false
      end

    if picture do
      ~E"""
        <span class="icon small"><img src="<%= picture %>" alt="<%= name %>"></span>
      """
    else
      ~E"""
      """
    end
  end

  def render("player_name.html", %{name: name}) do
    icon_part = render_player_icon(name)

    ~E"""
      <span><%= icon_part %><%= name %></span>
    """
  end
end
