defmodule Components.LeagueInfoModal do
  use Surface.LiveComponent
  alias Backend.Fantasy.League
  import BackendWeb.FantasyHelper
  use BackendWeb.ViewHelpers
  alias Components.Modal

  prop(show_modal, :boolean, default: false)
  prop(league, :map, required: true)

  prop(button_title, :string, default: "League Info")

  def render(assigns) do
    ~F"""
    <span>
      <Modal
      id={"modal_#{@id}"}
      button_title={@button_title}
      tittle={"#{@league.name} League Info"}>
      <table class="table is-fullwidth is-striped">
        <tbody>
         <tr :for={{info, value} <- info(@league)}>
          <td>{info}</td>
          <td>{value}</td>
        </tr>
        </tbody>
      </table>
      </Modal>
    </span>
    """
  end

  def info(league) do
    [
      {"Competition", league |> competition_name()},
      {"Roster Size", league.roster_size},
      {"Point System", league |> League.scoring_display()},
      {"Changes Between Rounds", league.changes_between_rounds},
      {"Draft Type", league |> draft_type_name()}
    ]
    |> add_draft_deadline(league)
  end

  defp add_draft_deadline(vals, %{real_time_draft: true}), do: vals

  defp add_draft_deadline(vals, %{real_time_draft: false, draft_deadline: draft_deadline}),
    do: vals ++ [{"Draft Deadline", render_datetime(draft_deadline)}]

  def handle_event("show_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: true)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: false)}
  end
end
