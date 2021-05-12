defmodule Components.GMProfileLink do
  @moduledoc false
  use Surface.Component
  alias BackendWeb.Router.Helpers, as: Routes
  import BackendWeb.LiveHelpers
  alias Backend.Grandmasters.Response.Competitor

  prop(week, :string)
  prop(gm, :map)

  def render(assigns) do
    ~H"""
    <span>
      <a :if={{ name = Competitor.name(@gm) }} class="link" href="{{ link(name, @week) }}">{{ name }}</a>
    </span>
    """
  end

  def link(name, week) do
    Routes.live_path(BackendWeb.Endpoint, BackendWeb.GrandmasterProfileLive, name, %{week: week})
  end
end
