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

  def render("player_name.html", %{name: name}) do
    if name in ["D0nkey", "D0nkey#2470"] do
      ~E"""
        <span><span class="icon small"><img src="/favicon.ico" alt="<%= name %>"></span><%= name %></span>
      """
    else
      name
    end
  end
end
