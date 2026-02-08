defmodule BackendWeb.PatreonController do
  use BackendWeb, :controller

  def webhook(conn, params) do
    text(conn, "success")
  end
end
