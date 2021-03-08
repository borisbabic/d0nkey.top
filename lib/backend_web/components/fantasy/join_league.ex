defmodule Components.JoinLeague do
  @moduledoc false
  use Surface.LiveComponent
  alias Backend.Fantasy
  prop(league, :map, required: true)
  prop(user, :map, required: true)
  prop(show_success, :map, default: false)
  prop(show_error, :map, default: false)

  def render(assigns) do
    ~H"""
    <div>
      <button class="button" type="button" :on-click="join"> Join League</button>
      <div :if={{ @show_success }} class="notification is-success tag">Success!</div>
      <div :if={{ @show_error }} class="notification is-warning tag">Failure!</div>
    </div>
    """
  end

  def handle_event("join", _, socket = %{assigns: %{user: user, league: league}}) do
    assigns =
      Fantasy.join_league(league, user)
      |> case do
        {:ok, _} -> [show_success: true, show_error: false]
        {:error, _} -> [show_error: true, show_success: false]
      end

    {
      :noreply,
      socket |> assign(assigns)
    }
  end
end
