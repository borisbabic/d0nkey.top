defmodule BackendWeb.DeckSheetsIndexLiveTest do
  use BackendWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Backend.Sheets

  test "renders insufficient permissions", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/deck-sheets")
    assert html =~ "Deck Sheets"
    assert html =~ "Please login"
  end

  @tag :authenticated
  test "renders when logged in", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/deck-sheets")
    assert html =~ "Deck Sheets"
    refute html =~ "Please login"
  end

  @tag :authenticated
  test "renders new button when logged in", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/deck-sheets")
    assert html =~ "New"
  end

  @tag :authenticated
  test "includes sheet", %{conn: conn, user: user} do
    %{sheet: %{name: name}} = create_sheet(user)
    {:ok, _view, html} = live(conn, "/deck-sheets")
    assert html =~ name
  end

  @tag :authenticated
  test "includes group sheet", %{conn: conn, user: user} do
    other_user = create_temp_user()

    {:ok, group = %{join_code: join_code, id: group_id}} =
      Backend.UserManager.create_group(%{"name" => "Test Group"}, other_user.id)

    {:ok, _} = Backend.UserManager.join_group(user, group_id, join_code)

    %{sheet: %{name: name}} = create_sheet(other_user, %{group: group})
    {:ok, _view, html} = live(conn, "/deck-sheets")
    assert html =~ name
  end

  @tag :authenticated
  test "successfully create new sheet", %{conn: conn, user: _user} do
    {:ok, view, html} = live(conn, "/deck-sheets")
    name = Ecto.UUID.generate()
    refute html =~ name

    click_result =
      view
      |> element("button", "New")
      |> render_click()

    assert click_result =~ "Save"

    view
    |> form("#sheet_form_new_deck_sheet_inner", %{
      deck_sheet: %{name: name, public_role: :nothing, group_role: :nothing}
    })
    |> render_submit()

    {:ok, _new_view, new_html} = live(conn, "/deck-sheets")
    assert new_html =~ name
  end

  @tag :authenticated
  test "successfully change sheet name", %{conn: conn, user: user} do
    %{sheet: %{id: id}} = create_sheet(user)
    {:ok, view, html} = live(conn, "/deck-sheets")
    new_name = Ecto.UUID.generate()
    refute html =~ new_name

    click_result =
      view
      |> element("button", "Edit")
      |> render_click()

    assert click_result =~ "Save"

    view
    |> form("#sheet_form_edit_deck_sheet_inner_#{id}", %{
      deck_sheet: %{name: new_name, public_role: :nothing, group_role: :nothing}
    })
    |> render_submit()

    {:ok, _new_view, new_html} = live(conn, "/deck-sheets")
    assert new_html =~ new_name
  end

  defp create_sheet(user, extra_attrs \\ %{}) do
    {name, attrs} = Map.pop_lazy(extra_attrs, :name, fn -> Ecto.UUID.generate() end)

    with {:ok, sheet} <- Sheets.create_deck_sheet(user, name, attrs) do
      %{sheet: sheet}
    end
  end
end
