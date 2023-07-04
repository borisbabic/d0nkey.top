defmodule BackendWeb.CompactLineupOnly do
  @moduledoc false
  use BackendWeb, :surface_live_view_no_layout

  import BackendWeb.LiveHelpers
  alias Components.CompactLineup
  data(extra_decks, :list)
  data(lineup, :any)
  data(component_id, :string)
  data(user, :any)

  def mount(_params, session, socket) do
    assigns = [
      extra_decks: Map.get(session, "extra_decks", []),
      lineup: Map.get(session, "lineup", nil),
      component_id: "compact_lineup_" <> Ecto.UUID.generate()
    ]

    {:ok, socket |> assign(assigns) |> assign_defaults(session) |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <CompactLineup id={@component_id} extra_decks={@extra_decks} lineup={@lineup} />
    """
  end
end
