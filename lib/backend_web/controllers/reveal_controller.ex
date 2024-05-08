defmodule BackendWeb.RevealController do
  use BackendWeb, :html_controller
  alias Backend.Reveals
  plug(:put_root_layout, {BackendWeb.LayoutView, "root.html"})
  plug(:put_layout, false)

  def boom(conn, _params) do
    user = BackendWeb.AuthUtils.user(conn)

    if Reveals.show?(:boom, user) do
      render(conn, :boom)
    else
      render(conn, :unallowed)
    end
  end
end
