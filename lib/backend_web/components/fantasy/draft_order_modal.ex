defmodule Components.DraftOrderModal do
  use Surface.LiveComponent
  alias Backend.Fantasy.League
  alias Backend.Fantasy.LeagueTeam
  alias Components.Modal

  prop(show_modal, :boolean, default: false)
  prop(league, :map, required: true)

  prop(button_title, :string, default: "Draft Order")

  def render(assigns) do
    ~F"""
    <span>
      <Modal
      button_title={@button_title}>
      title={"#{@league.name} Draft Order"}>
        <div class="level" :for={row <- pick_order_chunks(@league)}>
          <div class={"level-item #{pick_class(@league, index)} tag"} :for={{id, index} <- row}>
            {League.league_team!(@league, id) |> LeagueTeam.display_name()}
          </div>
        </div>
      </Modal>
    </span>
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
