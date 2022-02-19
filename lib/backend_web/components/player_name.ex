defmodule Components.PlayerName do
  @moduledoc """
  Render the player name, including player icon and optionally country flag
  """
  use BackendWeb, :surface_component

  prop(player, :string)
  prop(text_link, :string, default: nil)
  prop(flag, :boolean, default: true)
  prop(icon, :boolean, default: true)
  prop(link_class, :css_class, default: "")
  prop(shorten, :boolean, default: false)

  def render(assigns) do
    ~F"""
    <span>
      <span :if={(country = country(@player)) && @flag}>{country_flag(country)}</span>
      <span :if={@icon}>{render_player_icon(@player)}</span>
      <a class={@link_class} href={text_link(@text_link, @player)}>{text(@player, @shorten)}</a>
    </span>
    """
  end

  def text(player, false), do: player
  def text(player, true), do: Backend.Battlenet.Battletag.shorten(player)
  def text_link(nil, player), do: Routes.player_path(BackendWeb.Endpoint, :player_profile, player)
  def text_link(link, _), do: link

  def country(player), do: Backend.PlayerInfo.get_country(player)
end
