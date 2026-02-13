defmodule BackendWeb.ArchivedPatchesLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.PeriodTable

  def mount(_, session, socket) do
    {:ok, assign_defaults(socket, session) |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
    <div class="title is-2">Archived Patches</div>
    <PeriodTable periods={periods()} include_decks_link={true} include_meta_link={true}/>
    """
  end

  defp periods() do
    Hearthstone.DeckTracker.periods(type: "archive", order_by: {:period_start, :desc})
  end
end
