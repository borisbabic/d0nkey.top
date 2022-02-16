defmodule Components.GMProfileLink do
  @moduledoc false
  use Surface.Component
  alias BackendWeb.Router.Helpers, as: Routes
  use BackendWeb.ViewHelpers
  alias Backend.Grandmasters.Response.Competitor

  alias Components.PlayerName

  prop(week, :string)
  prop(link_text, :string, default: nil)
  prop(gm, :any)
  prop(link_class, :css_class, default: "")

  def render(assigns) do
    ~F"""
    <span>
      <a :if={name = name(@gm)}  :if={@link_text} class={"link is-text #{@link_class}"} href={"#{link(name, @week)}"}>
        {@link_text}
      </a>
      <PlayerName :if={name = name(@gm)} :if={! @link_text} player={name} text_link={link(name, @week)} link_class={@link_class}/>
    </span>
    """
  end

  def name(name) when is_binary(name), do: name
  def name(gm), do: Competitor.name(gm)

  def link(name, week) do
    Routes.live_path(BackendWeb.Endpoint, BackendWeb.GrandmasterProfileLive, name, %{week: week})
  end
end
