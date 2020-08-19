defmodule BackendWeb.PageController do
  use BackendWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def incubator(conn, _params) do
    render(conn, "incubator.html")
  end

  def donate_follow(conn, _params) do
    render(conn, "donate_follow.html")
  end
end
