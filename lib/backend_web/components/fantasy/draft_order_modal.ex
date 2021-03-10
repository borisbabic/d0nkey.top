defmodule Components.DraftOrderModal do
  use Surface.LiveComponent
  alias Backend.Fantasy.League
  alias Backend.Fantasy.LeagueTeam

  prop(show_modal, :boolean, default: false)
  prop(league, :map, required: true)

  prop(button_title, :string, default: "Draft Order")

  def render(assigns) do
    ~H"""
    <div>
      <button class="button" type="button" :on-click="show_modal">{{ @button_title }}</button>
      <div class="modal is-active" :if={{ @show_modal }}>
          <div class="modal-background"></div>
          <div class="modal-card">
            <header class="modal-card-head">
              <p class="modal-card-title">{{ @league.name }} Draft Order</p>
              <button class="delete" type="button" aria-label="close" :on-click="hide_modal"></button>
            </header>
            <section class="modal-card-body content">
              <div class="level" :for={{ row <- pick_order_chunks(@league) }}> 
                <div class="level-item {{ pick_class(@league, index) }} tag" :for={{ {id, index} <- row }}>
                  {{ League.league_team!(@league, id) |> LeagueTeam.display_name() }}
                </div>
              </div>
            </section>
          </div>
        </div>
    </div>
    """
  end

  defp pick_class(%{current_pick_number: current_pick_number}, index) do
    cond do
      current_pick_number > index -> ""
      current_pick_number == index -> "is-success"
      current_pick_number < index -> ""
    end
  end

  defp pick_order_chunks(%{pick_order: order = [_ | _], roster_size: roster_size}) do
    chunk_size = div(order |> Enum.count(), roster_size)
    order |> Enum.with_index() |> Enum.chunk_every(chunk_size)
  end

  defp pick_order_chunks(_), do: []

  def handle_event("show_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: true)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: false)}
  end
end
