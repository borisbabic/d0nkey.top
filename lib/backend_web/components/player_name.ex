defmodule Components.PlayerName do
  @moduledoc """
  Render the player name, including player icon and optionally country flag
  """
  use BackendWeb, :surface_component

  prop(player, :string)
  prop(display, :string, default: nil)
  prop(text_link, :string, default: nil)
  prop(flag, :boolean, default: true)
  prop(icon, :boolean, default: true)
  prop(link, :boolean, default: true)
  prop(link_class, :css_class, default: "")
  prop(shorten, :boolean, default: false)

  def render(assigns = %{player: nil}), do: ~F"<span>?</span>"

  def render(assigns) do
    ~F"""
    <span>
      <span :if={(country = country(@player)) && @flag}>{country_flag(country, @player)}</span>
      <span :if={@icon}>{render_player_icon(@player)}</span>
      <a :if={@link} class={@link_class} href={text_link(@text_link, @player)}>{@display || text(@player, @shorten)}</a>
      <span :if={!@link}>{@display || text(@player, @shorten)}</span>
    </span>
    """
  end

  # hack for worlds 2024
  def text("SnarkyPatron#1821", _), do: "mlyanming"
  def text("HozenPatron#1418", _), do: "Mesmile"
  def text(player, false), do: player
  def text(player, true), do: Backend.Battlenet.Battletag.shorten(player)
  def text_link(nil, player), do: Routes.player_path(BackendWeb.Endpoint, :player_profile, player)
  def text_link(link, _), do: link

  def country(player), do: Backend.PlayerInfo.get_country(player)
end
