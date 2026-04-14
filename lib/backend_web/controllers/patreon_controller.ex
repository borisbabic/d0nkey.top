defmodule BackendWeb.PatreonController do
  use BackendWeb, :controller

  def webhook(conn, _params) do
    text(conn, "success")
  end
end
