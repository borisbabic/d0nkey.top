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

  def hdt_plugin(conn, _params) do
    render(conn, "hdt-plugin.html")
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

  def ads_txt(conn, params) do
    if Application.get_env(:backend, :enable_adsense, true) do
      ads_txt = Backend.AdsTxtCache.get()
      text(conn, ads_txt)
    else
      conn
      |> put_status(302)
      |> redirect(external: Backend.AdsTxtCache.nitropay_url())
    end
  end

  def rick_astley(conn, params) do
    conn
    |> put_status(302)
    |> redirect(external: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
  end
end
