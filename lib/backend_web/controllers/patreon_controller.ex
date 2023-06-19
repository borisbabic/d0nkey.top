defmodule BackendWeb.PatreonController do
  use BackendWeb, :controller

  def webhook(conn, params) do
    IO.inspect(params)
    text(conn, "success")
  end
end
