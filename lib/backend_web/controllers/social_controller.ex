defmodule BackendWeb.SocialController do
  use BackendWeb, :controller

  def discord(conn, _) do
    redirect(conn, external: Constants.discord())
  end

  def paypal(conn, _) do
    redirect(conn, external: Constants.paypal())
  end

  def twitch(conn, _) do
    redirect(conn, external: Constants.twitch())
  end

  def patreon(conn, _) do
    redirect(conn, external: Constants.patreon())
  end

  def twitter(conn, _) do
    redirect(conn, external: Constants.twitter())
  end

  def notion(conn, _) do
    redirect(conn, external: Constants.notion())
  end

  def liberapay(conn, _) do
    redirect(conn, external: Constants.liberapay())
  end

  def btc(conn, _) do
    redirect(conn, external: Constants.btc())
  end
end
