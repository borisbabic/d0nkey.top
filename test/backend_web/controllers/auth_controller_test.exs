defmodule BackendWeb.AuthControllerTest do
  use BackendWeb.ConnCase
  use BackendWeb, :verified_routes
  alias BackendWeb.AuthController

  describe "sanitize_return_to/2" do
    test "allows valid relative paths with and without query params", %{conn: conn} do
      assert AuthController.sanitize_return_to("/decks?rank=top_legend", conn) ==
               "/decks?rank=top_legend"

      assert AuthController.sanitize_return_to("/decks", conn) == "/decks"

      assert AuthController.sanitize_return_to("/meta?format=2&period=patch", conn) ==
               "/meta?format=2&period=patch"

      assert AuthController.sanitize_return_to("/player-profile/Test%231234", conn) ==
               "/player-profile/Test%231234"
    end

    test "allows full URL if host matches conn.host", %{conn: conn} do
      url = "http://#{conn.host}/decks?rank=top_legend"
      assert AuthController.sanitize_return_to(url, conn) == "/decks?rank=top_legend"
    end

    test "rejects external hosts", %{conn: conn} do
      assert AuthController.sanitize_return_to("https://evil.com/decks?rank=top_legend", conn) == nil
      assert AuthController.sanitize_return_to("http://attacker.com", conn) == nil
    end

    test "rejects protocol-relative and malformed slashes", %{conn: conn} do
      assert AuthController.sanitize_return_to("//evil.com/decks", conn) == nil
      assert AuthController.sanitize_return_to("/\\evil.com", conn) == nil
      assert AuthController.sanitize_return_to("javascript:alert(1)", conn) == nil
    end

    test "rejects auth and logout paths", %{conn: conn} do
      assert AuthController.sanitize_return_to("/auth/bnet", conn) == nil
      assert AuthController.sanitize_return_to("/auth/bnet/callback", conn) == nil
      assert AuthController.sanitize_return_to("/logout", conn) == nil
    end

    test "handles nil, empty, or whitespace-only inputs", %{conn: conn} do
      assert AuthController.sanitize_return_to(nil, conn) == nil
      assert AuthController.sanitize_return_to("", conn) == nil
      assert AuthController.sanitize_return_to("   ", conn) == nil
      assert AuthController.sanitize_return_to(123, conn) == nil
    end
  end

  describe "GET /auth/bnet (request phase)" do
    test "saves redirect_to query param in session", %{conn: conn} do
      conn = get(conn, ~p"/auth/bnet?#{[redirect_to: "/decks?rank=top_legend"]}")
      assert get_session(conn, :return_to) == "/decks?rank=top_legend"
      assert response(conn, 302)
    end

    test "saves return_to query param in session", %{conn: conn} do
      conn = get(conn, ~p"/auth/bnet?#{[return_to: "/decks?format=2"]}")
      assert get_session(conn, :return_to) == "/decks?format=2"
      assert response(conn, 302)
    end

    test "saves referer header when redirect_to is not provided", %{conn: conn} do
      conn =
        conn
        |> put_req_header("referer", "http://#{conn.host}/decks?rank=top_legend")
        |> get(~p"/auth/bnet")

      assert get_session(conn, :return_to) == "/decks?rank=top_legend"
      assert response(conn, 302)
    end

    test "does not save invalid or external redirect_to in session", %{conn: conn} do
      conn = get(conn, ~p"/auth/bnet?#{[redirect_to: "https://evil.com/phish"]}")
      assert get_session(conn, :return_to) == nil
      assert response(conn, 302)
    end
  end

  describe "GET /auth/bnet/callback" do
    @auth_payload %{
      provider: :bnet,
      uid: "99887766",
      info: %{nickname: "Tester#1234"}
    }

    test "redirects to stored return_to URL on successful login and clears session", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{return_to: "/decks?rank=top_legend"})
        |> assign(:ueberauth_auth, @auth_payload)
        |> get(~p"/auth/bnet/callback")

      assert redirected_to(conn, 302) == "/decks?rank=top_legend"
      assert get_session(conn, :return_to) == nil
    end

    test "redirects to '/' when no return_to is stored", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{})
        |> assign(:ueberauth_auth, @auth_payload)
        |> get(~p"/auth/bnet/callback")

      assert redirected_to(conn, 302) == "/"
      assert get_session(conn, :return_to) == nil
    end

    test "clears return_to on auth failure and redirects to '/'", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{return_to: "/decks?rank=top_legend"})
        |> assign(:ueberauth_fail, :some_failure)
        |> get(~p"/auth/bnet/callback")

      assert redirected_to(conn, 302) == "/"
      assert get_session(conn, :return_to) == nil
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Failed to auth"
    end
  end

  describe "GET /logout" do
    test "redirects to redirect_to query param and signs out", %{conn: conn} do
      conn = get(conn, ~p"/logout?#{[redirect_to: "/decks?rank=top_legend"]}")
      assert redirected_to(conn, 302) == "/decks?rank=top_legend"
      assert get_session(conn, :return_to) == nil
    end

    test "redirects to return_to query param and signs out", %{conn: conn} do
      conn = get(conn, ~p"/logout?#{[return_to: "/meta?format=2"]}")
      assert redirected_to(conn, 302) == "/meta?format=2"
      assert get_session(conn, :return_to) == nil
    end

    test "redirects to referer header when param is not provided", %{conn: conn} do
      conn =
        conn
        |> put_req_header("referer", "http://#{conn.host}/decks?rank=top_legend")
        |> get(~p"/logout")

      assert redirected_to(conn, 302) == "/decks?rank=top_legend"
    end

    test "redirects to '/' when no return URL is provided or invalid", %{conn: conn} do
      conn = get(conn, ~p"/logout")
      assert redirected_to(conn, 302) == "/"

      conn = get(conn, ~p"/logout?#{[redirect_to: "https://evil.com/logout"]}")
      assert redirected_to(conn, 302) == "/"
    end
  end
end
