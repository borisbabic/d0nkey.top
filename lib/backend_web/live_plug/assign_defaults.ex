defmodule BackendWeb.LivePlug.AssignDefaults do
  @moduledoc "Adds the user to the socket and context"
  import BackendWeb.LiveHelpers, only: [assign_defaults: 2]

  def on_mount(_, _params, session, socket) do
    {:cont, socket |> assign_defaults(session) |> put_user_in_context()}
  end

  def put_user_in_context(%{assigns: %{user: user} = assigns} = socket) do
    is_mobile = assigns[:is_mobile] || false

    socket
    |> Surface.Components.Context.put(user: user)
    |> Surface.Components.Context.put(is_mobile: is_mobile)
  end

  def put_user_in_context(socket) do
    is_mobile = socket.assigns[:is_mobile] || false

    socket
    |> Surface.Components.Context.put(user: nil)
    |> Surface.Components.Context.put(is_mobile: is_mobile)
  end
end
