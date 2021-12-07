defmodule Components.ClassStatsModal do
  @moduledoc false
  use Surface.LiveComponent

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
              <table class="table is-fullwidth is-striped">
                <thead>
                  <tr>
                    <th>Class</th>
                    <th>Winrate</th>
                    <th>Total Games</th>
                  </tr>
                </thead>
                <tbody>
                  <tr :for={stat <- stats}>
                    <td>{class_name(stat)}</td>
                    <td>{Float.round(stat.winrate * 100, 1)}</td>
                    <td>{stat.total}</td>
                  </tr>
                  <tr :if={total_stats = Hearthstone.DeckTracker.sum_stats(stats)}>
                    <td>Total</td>
                    <td>{Float.round(total_stats.winrate * 100, 1)}</td>
                    <td>{total_stats.total}</td>
                  </tr>
                </tbody>
              </table>
            </section>
          </div>
        </div>
    </div>
    """
  end

  def class_name(stat) do
    stat
    |> extract_class()
    |> Backend.Hearthstone.Deck.class_name()
  end
  def extract_class(%{player_class: class}), do: class
  def extract_class(%{opponent_class: class}), do: class
  def extract_class(%{class: class}), do: class

  def handle_event("show_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: true)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: false)}
  end
end
