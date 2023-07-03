defmodule BackendWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.Component, only: [assign: 3]

  def assign_defaults(socket, session) do
    user = load_user(session)

    socket
    |> assign(:user, user)
  end

  alias Backend.UserManager.User
  alias Backend.UserManager.Guardian

  @spec load_user(Map.t() | any) :: User | nil
  def load_user(%{"guardian_default_token" => token}) do
    token
    |> Guardian.resource_from_token()
    |> case do
      {:ok, user, _} -> user
      _ -> nil
    end
  end

  def load_user(_), do: nil

  def assign_meta_tags(socket, new_tags = %{}) do
    meta = (get_in(socket.assigns, [:meta_tags]) || %{}) |> Map.merge(new_tags)
    socket |> assign(:meta_tags, meta)
  end
end
