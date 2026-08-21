defmodule BackendWeb.AuthController do
  use BackendWeb, :controller
  plug :save_return_to when action in [:request]
  plug Ueberauth

  alias Backend.UserManager
  alias Backend.UserManager.Guardian

  def callback(%{assigns: %{ueberauth_fail: _fails}} = conn, _params) do
    conn
    |> delete_session(:return_to)
    |> put_flash(:error, "Failed to auth")
    |> redirect(to: "/")
  end

  def callback(
        %{assigns: %{ueberauth_auth: %{provider: :patreon, uid: patreon_id}}} = conn,
        _params
      ) do
    case Guardian.Plug.current_resource(conn) do
      %{battletag: _bt} = user ->
        UserManager.set_patreon(user, patreon_id)
        conn |> redirect(to: "/profile/settings")

      _ ->
        render(conn, "user_expected.html", %{})
    end
  end

  def callback(%{assigns: %{ueberauth_auth: %{provider: :bnet} = auth}} = conn, _params) do
    user =
      auth
      |> get_bnet_info()
      |> UserManager.ensure_bnet_user()

    return_to =
      conn
      |> get_session(:return_to)
      |> sanitize_return_to(conn)
      |> Kernel.||("/")

    conn
    |> delete_session(:return_to)
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: return_to)
  end

  def callback(
        %{assigns: %{ueberauth_auth: %{provider: :twitch, uid: twitch_id} = uberauth}} = conn,
        _params
      ) do
    case Guardian.Plug.current_resource(conn) do
      %{battletag: _bt} = user ->
        UserManager.set_twitch(user, twitch_id)
        create_streamer_from_info(twitch_id, uberauth)
        conn |> redirect(to: "/profile/settings")

      _ ->
        render(conn, "user_expected.html", %{})
    end
  end

  def callback(conn, _params) do
    conn
    |> delete_session(:return_to)
    |> put_flash(
      :error,
      "Unknown issue when authing, please contact d0nkey if it persists after trying again later"
    )
    |> redirect(to: "/")
  end

  defp save_return_to(conn, _opts) do
    return_to =
      conn.params["redirect_to"] ||
        conn.params["return_to"] ||
        get_req_header(conn, "referer") |> List.first()

    case sanitize_return_to(return_to, conn) do
      nil ->
        conn

      path when path in ["", "/"] ->
        conn

      path ->
        put_session(conn, :return_to, path)
    end
  end

  @doc false
  def sanitize_return_to(url, conn) when is_binary(url) do
    url = String.trim(url)

    with %URI{host: host, path: path, query: query} <- URI.parse(url),
         true <- allowed_return_to?(path) do
      "#{path}?#{query || ""}"
    else
      _ -> nil
    end
  end

  def sanitize_return_to(_, _), do: nil

  def allowed_return_to?(empty) when empty in ["/", ""], do: false
  def allowed_return_to?("/auth" <> _), do: false
  def allowed_return_to?("/logout" <> _), do: false
  def allowed_return_to?("//" <> _), do: false
  def allowed_return_to?("/\\" <> _), do: false

  def allowed_return_to?(path) do
    String.starts_with?(path, "/")
  end

  defp create_streamer_from_info(twitch_id, %{
         info: %{name: twitch_display, nickname: twitch_login}
       }) do
    Backend.Streaming.get_or_create_streamer(twitch_id, %{
      twitch_login: twitch_login,
      twitch_display: twitch_display
    })
  end

  defp create_streamer_from_info(_, _), do: nil

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

  def logout(conn, params) do
    return_to =
      params["redirect_to"] ||
        params["return_to"] ||
        get_req_header(conn, "referer") |> List.first()

    return_to =
      return_to
      |> sanitize_return_to(conn)
      |> Kernel.||("/")

    conn
    |> delete_session(:return_to)
    |> Guardian.Plug.sign_out()
    |> redirect(to: return_to)
  end
end
