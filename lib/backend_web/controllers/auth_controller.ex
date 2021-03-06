defmodule BackendWeb.AuthController do
  use BackendWeb, :controller
  plug Ueberauth

  alias Backend.UserManager
  alias Backend.UserManager.Guardian

  def callback(conn = %{assigns: %{ueberauth_fail: _fails}}, _params) do
    conn
    |> put_flash(:error, "Failed to auth")
    |> redirect(to: "/")
  end

  def callback(conn = %{assigns: %{ueberauth_auth: auth = %{provider: :bnet}}}, _params) do
    user =
      auth
      |> get_bnet_info()
      |> UserManager.ensure_bnet_user()

    conn
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/")
  end

  @spec get_bnet_info(any()) :: UserManager.bnet_info()
  def get_bnet_info(%{extra: %{user: %{"battletag" => bt, "id" => id}}}) do
    %{
      battletag: bt,
      bnet_id: to_string(id)
    }
  end

  def get_bnet_info(%{uid: id, info: %{nickname: bt}}) do
    %{
      battletag: bt,
      bnet_id: to_string(id)
    }
  end

  def get_bnet_info(_), do: raise("Can't get bnet info")

  def login_welcome(conn, params) do
    response =
      conn
      |> Guardian.Plug.current_resource()
      |> case do
        user = %{battletag: bt} -> render(conn, "login_welcome.html", %{user: user})
        _ -> render(conn, "user_expected.html", %{})
      end

    text(conn, response)
  end

  def callback(conn, _params) do
    conn
    |> put_flash(
      :error,
      "Unknown issue when authing, please contact d0nkey if it persists after trying again later"
    )
    |> redirect(to: "/")
  end

  def who_am_i(conn, _params) do
    response =
      conn
      |> Guardian.Plug.current_resource()
      |> case do
        %{battletag: bt} -> "Hello #{bt}"
        _ -> "None of my business, it appears"
      end

    text(conn, response)
  end

  def logout(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: "/")
  end
end
