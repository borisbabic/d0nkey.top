defmodule BackendWeb.PageController do
  use BackendWeb, :controller
  require Logger

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def incubator(conn, _params) do
    render(conn, "incubator.html")
  end

  def donate_follow(conn, _params) do
    render(conn, "donate_follow.html")
  end

  def about(conn, _params) do
    render(conn, "about.html")
  end

  def privacy(conn, _params) do
    render(conn, "privacy.html")
  end

  def test(conn, params) do
    render(conn, "test.html", params)
  end

  def log(conn, params) do
    ret = Jason.encode!(params, pretty: true)
    IO.inspect(conn)
    Logger.info(ret)
    Logger.info(ret)

    text(conn, ret)
  end
end
