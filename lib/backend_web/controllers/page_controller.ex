defmodule BackendWeb.PageController do
  use BackendWeb, :controller
  alias Backend.AdsTxtCache
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

  def disabled(conn, _params) do
    text(conn, "This page has been temporarily disabled")
  end

  def log(conn, params) do
    ret = Jason.encode!(params, pretty: true)
    IO.inspect(conn)
    Logger.info(ret)
    Logger.info(ret)

    text(conn, ret)
  end

  @spec ads_txt(Plug.Conn.t(), Map.t()) :: Plug.Conn.t()
  def ads_txt(conn, _params) do
    config = AdsTxtCache.config()

    default_config = %{
      enable_adsense: false,
      nitropay_url: "https://api.nitropay.com/v1/ads-1847.txt"
    }

    %{nitropay_url: url, enable_adsense: adsense} =
      Enum.find_value(config, default_config, fn {host, config} ->
        if conn.host =~ host do
          config
        end
      end)

    if adsense do
      ads_txt = AdsTxtCache.get(url)
      text(conn, ads_txt)
    else
      conn
      |> put_status(302)
      |> redirect(external: url)
    end
  end

  def bla_bla(conn, params) do
    render(conn, "bla_bla.html", params)
  end

  def always_error(_conn, params) do
    error =
      case params do
        %{"error" => error} -> error
        _ -> "Random error #{Ecto.UUID.generate()}"
      end

    raise error
  end

  def rick_astley(conn, params) do
    render(conn, "rick_roll.html", params)
    # conn
    # |> put_status(302)
    # |> redirect(external: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
  end
end
