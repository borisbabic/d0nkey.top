defmodule Components.ClassStatsModal do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.ClassStatsTable

  prop(show_modal, :boolean, default: false)
  prop(title, :string, required: false)
  prop(button_title, :string, required: false)
  prop(modal_title, :string, required: false)
  prop(get_stats, :fun, required: true)
  prop(class, :css_class)
  @default_title "Class Stats"
  def render(assigns) do
    button_title = assigns.button_title || assigns.title || @default_title
    modal_title = assigns.modal_title || assigns.title || @default_title
    ~F"""
    <div class={@class}>
      <button class="button" type="button" :on-click="show_modal">{button_title}</button>
      <div class="modal is-active" :if={@show_modal}>
          <div class="modal-background"></div>
          <div class="modal-card">
            <header class="modal-card-head">
              <p class="modal-card-title">{modal_title}</p>
              <button class="delete" type="button" aria-label="close" :on-click="hide_modal"></button>
            </header>
            <section :if={stats = @get_stats.()} class="modal-card-body content">
              <ClassStatsTable stats={stats} />
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
