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

  def callback(
        conn = %{assigns: %{ueberauth_auth: uberauth = %{provider: :twitch, uid: twitch_id}}},
        _params
      ) do
    case Guardian.Plug.current_resource(conn) do
      user = %{battletag: _bt} ->
        UserManager.set_twitch(user, twitch_id)
        create_streamer_from_info(twitch_id, uberauth)
        conn |> redirect(to: "/profile/settings")

      _ ->
        render(conn, "user_expected.html", %{})
    end
  end

  defp create_streamer_from_info(twitch_id, %{info: %{name: twitch_display, nickname: twitch_login}}) do
    Backend.Streaming.get_or_create_streamer(twitch_id, %{twitch_login: twitch_login, twitch_display: twitch_display})
  end
  defp create_streamer_from_info(_), do: nil

  def callback(conn, _params) do
    conn
    |> put_flash(
      :error,
      "Unknown issue when authing, please contact d0nkey if it persists after trying again later"
    )
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

  def login_welcome(conn, _params) do
    response =
      conn
      |> Guardian.Plug.current_resource()
      |> case do
        user = %{battletag: _bt} -> render(conn, "login_welcome.html", %{user: user})
        _ -> render(conn, "user_expected.html", %{})
      end

    text(conn, response)
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
