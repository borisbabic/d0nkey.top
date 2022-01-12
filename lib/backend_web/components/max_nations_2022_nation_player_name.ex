defmodule Components.MaxNations2022NationPlayerName do
  use Surface.Component
  use BackendWeb.ViewHelpers
  alias BackendWeb.Router.Helpers, as: Routes
  alias Backend.MaxNations2022

  prop(player, :string, required: true)
  prop(nation, :string, required: false)
  def render(assigns) do
    ~F"""
      <span>
        <a :if={nation = nation(@nation, @player)} href={Routes.live_path(BackendWeb.Endpoint, BackendWeb.MaxNations2022NationLive, nation)}>{Util.get_country_code(nation) |> country_flag()}</a>
        <a href={Routes.live_path(BackendWeb.Endpoint, BackendWeb.MaxNations2022PlayerLive, @player)}>{@player}</a>
      </span>
    """
  end
  def nation(nil, player) do
    MaxNations2022.get_nation(player)
  end
  def nation(nation, _), do: nation
end
