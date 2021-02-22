defmodule Backend.Plug.AdminAuth do
  @moduledoc "Plug for authenticating admin roles"
  import Plug.Conn
  alias Backend.UserManager.User

  def init(default), do: default

  def call(conn, role: role) do
    conn
    |> Guardian.Plug.current_resource()
    |> User.can_access?(role)
    |> unauth(conn)
  end

  defp unauth(true, conn), do: conn
  defp unauth(false, conn), do: unauth(conn)

  defp unauth(conn) do
    conn
    |> halt()
    |> BackendWeb.FallbackController.unauthorized()
  end
end
