defmodule Components.PlayerName do
  @moduledoc """
  Render the player name, including player icon and optionally country flag
  """
  use Surface.Component
  use BackendWeb.ViewHelpers

  prop(player, :string)
  prop(text_link, :string, default: nil)
  prop(flag, :boolean, default: false)
  prop(icon, :boolean, default: true)
  prop(link_class, :css_class, default: "")

  def render(assigns) do
    ~F"""
    <span>
      <span :if={(country = country(@player)) && @flag}>{country_flag(country)}</span>
      <span :if={@icon}>{render_player_icon(@player)}</span>
      <a :if={@text_link} class={@link_class} href={@text_link}>{@player}</a>
      <span :if={! @text_link}>{@player}</span>
    </span>
    """
  end

  def country(player), do: Backend.UserManagerInfo.get_country(player)
end
