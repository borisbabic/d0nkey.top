defmodule BackendWeb.ImportCountriesFromBattlefyLive do
  @moduledoc false
  use BackendWeb, :surface_live_view_no_layout

  import BackendWeb.LiveHelpers
  alias Components.ImportCountriesFromBattlenetButton

  data(tournament_id, :string)
  data(user, :any)

  def mount(_params, session = %{"tournament_id" => id}, socket) do
    {:ok,
     socket
     |> assign(tournament_id: id)
     |> assign_defaults(session)
     |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <ImportCountriesFromBattlenetButton id={"import_live_from_#{@tournament_id}"} user={@user} tournament_id={@tournament_id} />
    """
  end
end
