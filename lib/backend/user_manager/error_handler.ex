defmodule Backend.UserManager.ErrorHandler do
  @moduledoc false
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {:invalid_token, _}, _) do
    conn
    |> Backend.UserManager.Guardian.Plug.sign_out()
    |> Phoenix.Controller.redirect(to: "/")
  end

  def auth_error(conn, {type, _reason}, _opts) do
    body = to_string(type)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(401, body)
  end
end
