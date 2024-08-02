defmodule BackendWeb.LivePlug.AdminAuth do
  alias BackendWeb.LiveHelpers
  alias Backend.UserManager.User

  def on_mount(role, _params, session, socket) do
    with %User{} = user <- extract_user(socket, session),
         true <- User.can_access?(user, role) do
      {:cont, socket}
    else
      _ -> {:halt, Phoenix.LiveView.redirect(socket, to: "/unauthorized")}
    end
  end

  defp extract_user(%{assigns: %{user: user}}, _session) when not is_nil(user), do: user
  defp extract_user(_socket, session), do: LiveHelpers.load_user(session)
end
