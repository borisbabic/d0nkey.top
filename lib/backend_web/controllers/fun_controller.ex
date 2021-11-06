defmodule BackendWeb.FunController do
  use BackendWeb, :controller

  def wild(conn, params) do
    render(conn, "wild.html", params)
  end
end
