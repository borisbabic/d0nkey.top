defmodule Components.GMProfileLink do
  @moduledoc false
  use Surface.Component
  alias BackendWeb.Router.Helpers, as: Routes
  alias Backend.Grandmasters.Response.Competitor

  prop(week, :string)
  prop(link_text, :string, default: nil)
  prop(gm, :any)
  prop(link_class, :css_class, default: "")

  def render(assigns) do
    ~H"""
    <span>
      <a :if={{ name = name(@gm) }} class="link is-text {{ @link_class }}" href="{{ link(name, @week) }}">{{ @link_text || name }}</a>
    </span>
    """
  end

  def name(name) when is_binary(name), do: name
  def name(gm), do: Competitor.name(gm)

  def link(name, week) do
    Routes.live_path(BackendWeb.Endpoint, BackendWeb.GrandmasterProfileLive, name, %{week: week})
  end
end
