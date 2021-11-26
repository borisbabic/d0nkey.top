defmodule Components.OmniBarHelp do
  @moduledoc false
  use Surface.LiveComponent
  use BackendWeb.ViewHelpers
  prop(show_modal, :boolean, default: false)
  prop(title, :string, default: "Omni Bar")

  def render(assigns) do
    ~F"""
    <div>
      <button class="button icon" type="button" :on-click="show_modal"><i class="fas fa-info-circle"></i></button>
      <div class="modal is-active" :if={@show_modal}>
          <div class="modal-background"></div>
          <div class="modal-card">
            <header class="modal-card-head">
              <p class="modal-card-title">{@title}</p>
              <button class="delete" type="button" aria-label="close" :on-click="hide_modal"></button>
            </header>
            <section class="modal-card-body content">
              <div>
                Type or paste something to get relevant links. Currently supported:
              </div>
              <ul :for={thing <- ["Battlefy link", "Deckcode", "Battletags"]}>
                <li>{thing}</li>
              </ul>
              <div>
                More is planned! If you have an idea join my discord to share it after checking the pinned post
              </div>
            </section>
          </div>
      </div>
    </div>
    """
  end

  def handle_event("show_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: true)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: false)}
  end
end
