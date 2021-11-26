defmodule Components.GMStandingsModal do
  @moduledoc false

  use Surface.LiveComponent
  use BackendWeb.ViewHelpers

  alias Backend.Grandmasters

  prop(show_modal, :boolean, default: false)
  prop(region, :atom, default: :APAC)
  prop(week, :string, default: nil)
  prop(button_title, :string, default: "GM Standings")
  prop(title, :string, default: "GM Standings")

  def render(assigns) do
    ~F"""
    <div>
      <button class="button" type="button" :on-click="show_modal">{@button_title}</button>
      <div class="modal is-active" :if={@show_modal}>
          <div class="modal-background"></div>
          <div class="modal-card">
            <header class="modal-card-head">
              <p class="modal-card-title">{@title}</p>
              <button class="delete" type="button" aria-label="close" :on-click="hide_modal"></button>
            </header>
            <section class="modal-card-body content">
              <ul :for={{player, points} <- results(@region, @week)}>
                <li><span>{points} - </span>{player}</li>
              </ul>
            </section>
          </div>
      </div>
    </div>
    """
  end

  def results(region, nil) do
    Grandmasters.region_results(region)
  end

  def results(region, week) do
    Grandmasters.region_results(region, week)
  end

  def handle_event("show_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: true)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: false)}
  end
end
