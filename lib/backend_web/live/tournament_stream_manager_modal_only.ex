defmodule BackendWeb.TournamentStreamManagerModalOnlyLive do
  @moduledoc false
  use BackendWeb, :surface_live_view_no_layout

  import BackendWeb.LiveHelpers
  alias Components.TournamentStreamManagerModal

  data(tournament_source, :string)
  data(tournament_id, :string)
  data(user, :any)

  def mount(_params, session = %{"tournament_source" => source, "tournament_id" => id}, socket) do
    {:ok,
     socket
     |> assign(tournament_source: source, tournament_id: id)
     |> assign_defaults(session)
     |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <TournamentStreamManagerModal user={@user} tournament_source={@tournament_source} tournament_id={@tournament_id} id={"#{@tournament_source}/#{@tournament_id}/only_modal"} />
    """
  end
end
