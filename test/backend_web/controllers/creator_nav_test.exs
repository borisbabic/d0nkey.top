defmodule BackendWeb.CreatorNavTest do
  use BackendWeb.ConnCase
  alias Backend.Creators

  defp navbar(conn) do
    conn
    |> get(Routes.empty_path(conn, :with_nav))
    |> html_response(200)
    |> LazyHTML.from_document()
    |> LazyHTML.query("#main-navbar")
  end

  defp review_link(navbar), do: LazyHTML.query(navbar, "a[href='/admin/creator-slugs']")
  defp text(node), do: node |> LazyHTML.text() |> String.trim()

  defp request_slugs(count) do
    for i <- 1..count//1 do
      {:ok, _} = Creators.request_slug(create_temp_user(), "pending_slug_#{i}")
    end
  end

  test "super admins see the review link and counts" do
    admin = create_temp_user(%{battletag: "Admin#1234", admin_roles: ["super"]})
    conn = BackendWeb.ConnCase.build_conn_with_user(admin)
    request_slugs(2)

    nav = navbar(conn)
    assert nav |> review_link() |> text() =~ "Creator URL Requests (2)"
    assert nav |> LazyHTML.text() =~ "Admin#1234 (2)"
  end

  test "no counts when nothing is pending" do
    admin = create_temp_user(%{battletag: "Admin#1234", admin_roles: ["super"]})
    nav = admin |> BackendWeb.ConnCase.build_conn_with_user() |> navbar()

    link_text = nav |> review_link() |> text()
    assert link_text =~ "Creator URL Requests"
    refute link_text =~ "("
    refute nav |> LazyHTML.text() =~ "Admin#1234 ("
  end

  test "other users don't see the link or counts" do
    user = create_temp_user(%{battletag: "Regular#1234", admin_roles: ["archetyping"]})
    request_slugs(1)
    nav = user |> BackendWeb.ConnCase.build_conn_with_user() |> navbar()

    assert nav |> review_link() |> Enum.empty?()
    refute nav |> LazyHTML.text() =~ "Regular#1234 ("
  end
end
