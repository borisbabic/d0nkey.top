defmodule BackendWeb.ApiController do
  use BackendWeb, :controller

  def who_am_i(conn, _params) do
    case conn.assigns[:api_user] do
      nil -> text(conn, "")
      user -> text(conn, user.username)
    end
  end
end
