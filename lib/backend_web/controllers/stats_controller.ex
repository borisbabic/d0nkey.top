defmodule BackendWeb.StatsController do
  use BackendWeb, :html_controller

  plug(:put_layout, false)

  def explanation(conn, params) do
    render(conn, :explanation)
  end
end
