defmodule BackendWeb.AuthUtils do
  @moduledoc "Utilities related to the Conn and auth"
  alias Backend.UserManager.User

  @spec user(Plug.Conn.t()) :: User.t() | nil
  def user(conn), do: conn |> Guardian.Plug.current_resource()

  @spec admin_roles(Plug.Conn.t()) :: [String.t()]
  def admin_roles(conn) do
    conn
    |> user()
    |> case do
      %{admin_roles: ar} when is_list(ar) -> ar
      _ -> []
    end
  end

  @spec can_access?(Plug.Conn.t(), String.t()) :: boolean
  def can_access?(conn, role), do: conn |> user() |> User.can_access?(role)

  def battletag(conn) do
    conn
    |> user()
    |> case do
      %{battletag: battletag} -> battletag
      _ -> nil
    end
  end
end
