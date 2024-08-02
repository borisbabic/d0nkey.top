defmodule BackendWeb.LivePlug.AssignDefaults do
  @moduledoc "Adds the user to the socket and context"
  import BackendWeb.LiveHelpers, only: [assign_defaults: 2]

  def on_mount(_, _params, session, socket) do
    {:cont, socket |> assign_defaults(session) |> put_user_in_context()}
  end

  def put_user_in_context(%{assigns: %{user: user}} = socket) do
    Surface.Components.Context.put(socket, user: user)
  end

  def put_user_in_context(socket) do
    Surface.Components.Context.put(socket, user: nil)
  end
end
