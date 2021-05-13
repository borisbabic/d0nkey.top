defmodule Components.GMProfileLink do
  @moduledoc false
  use Surface.Component
  alias BackendWeb.Router.Helpers, as: Routes
  import BackendWeb.LiveHelpers
  alias Backend.Grandmasters.Response.Competitor

  prop(week, :string)
  prop(gm, :any)

  def render(assigns) do
    ~H"""
    <span>
      <a :if={{ name = name(@gm) }} class="link" href="{{ link(name, @week) }}">{{ name }}</a>
    </span>
    """
  end

  def name(name) when is_binary(name), do: name
  def name(gm), do: Competitor.name(gm)

  def link(name, week) do
    Routes.live_path(BackendWeb.Endpoint, BackendWeb.GrandmasterProfileLive, name, %{week: week})
  end
end
