defmodule Components.ArchetypeStatsModal do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.ArchetypeStatsTable
  alias FunctionComponents.Dropdown

  prop(show_modal, :boolean, default: false)
  prop(title, :string, required: false)
  prop(button_title, :string, required: false)
  prop(modal_title, :string, required: false)
  prop(get_stats, :fun, required: true)
  prop(class, :css_class)
  prop(minimum_games, :number, default: 1)
  prop(min_minimum_games, :number, default: 1)
  prop(show_minimum_dropdown, :boolean, default: true)
  data(default_title, :string, default: "Archetype Stats")

  def render(assigns) do
    ~F"""
    <div class={@class}>
      <button class="button" type="button" :on-click="show_modal">{@button_title || @title || @default_title}</button>
      <div class="modal is-active" :if={@show_modal}>
          <div class="modal-background"></div>
          <div class="modal-card">
            <header class="modal-card-head">
              <p class="modal-card-title">{@modal_title || @title || @default_title}</p>
              <button class="delete" type="button" aria-label="close" :on-click="hide_modal"></button>
            </header>
            <section :if={stats = @get_stats.()} class="modal-card-body content">
              <Dropdown.menu title="Min Games" :if={@show_minimum_dropdown}>
                <Dropdown.item :for={minimum_games <- minimum_games_options(@min_minimum_games) } selected={minimum_games == @minimum_games} phx-target={@myself} phx-click="set-minimum" phx-value-minimum_games={minimum_games} >
                  {minimum_games}
                </Dropdown.item>
              </Dropdown.menu>
              <ArchetypeStatsTable stats={stats} minimum_games={@minimum_games}/>
            </section>
          </div>
        </div>
    </div>
    """
  end

  def minimum_games_options(min_minimum_games) do
    [1, 5, 10, 20, 30, 40, 50, 75, 100, 250, 500, 1000, 2500, 5000, 10000]
    |> Enum.filter(&(&1 >= min_minimum_games))
  end

  def handle_event("set-minimum", %{"minimum_games" => min}, socket) do
    {:noreply, socket |> assign(minimum_games: Util.to_int_or_orig(min))}
  end

  def handle_event("show_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: true)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: false)}
  end
end
