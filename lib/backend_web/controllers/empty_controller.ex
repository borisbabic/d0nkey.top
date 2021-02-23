defmodule BackendWeb.EmptyController do
  use BackendWeb, :controller

  def with_nav(conn, _params) do
    render(conn, "with_nav.html", %{})
  end

  def without_nav(conn, _params) do
    conn
    |> text("")
  end
end
