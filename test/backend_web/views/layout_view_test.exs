defmodule BackendWeb.LayoutViewTest do
  use BackendWeb.ConnCase
  import Phoenix.LiveViewTest

  test "renders info flash message in flash_group" do
    html = render_component(&BackendWeb.Layouts.flash_group/1, flash: %{"info" => "Operation successful"})
    assert html =~ "Operation successful"
    assert html =~ "flash-toast-info"
    assert html =~ "flash-info"
  end

  test "renders error flash message in flash_group" do
    html = render_component(&BackendWeb.Layouts.flash_group/1, flash: %{"error" => "Something broke"})
    assert html =~ "Something broke"
    assert html =~ "flash-toast-error"
    assert html =~ "flash-error"
  end

  test "renders notice flash message as info in flash_group" do
    html = render_component(&BackendWeb.Layouts.flash_group/1, flash: %{"notice" => "Take notice"})
    assert html =~ "Take notice"
    assert html =~ "flash-toast-info"
  end

  test "renders success and warning flash messages" do
    html_success = render_component(&BackendWeb.Layouts.flash_group/1, flash: %{"success" => "Great job"})
    assert html_success =~ "Great job"
    assert html_success =~ "flash-toast-success"

    html_warning = render_component(&BackendWeb.Layouts.flash_group/1, flash: %{"warning" => "Watch out"})
    assert html_warning =~ "Watch out"
    assert html_warning =~ "flash-toast-warning"
  end

  test "renders app layout with flash", %{conn: conn} do
    html =
      Phoenix.View.render_to_string(
        BackendWeb.LayoutView,
        "app.html",
        conn: conn,
        flash: %{"info" => "Saved successfully"},
        inner_content: "<div>Content</div>"
      )

    assert html =~ "Saved successfully"
    assert html =~ "flash-toast-info"
    assert html =~ "Content"
  end

  test "renders live layout with flash" do
    html =
      Phoenix.View.render_to_string(
        BackendWeb.LayoutView,
        "live.html",
        flash: %{"error" => "Live error"},
        inner_content: "<div>Live Content</div>"
      )

    assert html =~ "Live error"
    assert html =~ "flash-toast-error"
    assert html =~ "Live Content"
  end

  test "renders flash with toast styling, 20s timeout, and progress bar" do
    html = render_component(&BackendWeb.Layouts.flash_group/1, flash: %{"info" => "Auto dismiss info"})
    assert html =~ "flash-toast"
    assert html =~ "flash-toast-info"
    assert html =~ ~s(data-timeout="20000")
    assert html =~ "flash-progress"
    assert html =~ "phx-hook=\"FlashGroup\""
  end

  test "renders flash without progress bar when timeout is nil" do
    html =
      render_component(&FunctionComponents.CoreComponents.flash/1,
        kind: :info,
        timeout: nil,
        inner_block: [%{inner_block: fn _, _ -> "No timeout" end}]
      )

    assert html =~ "No timeout"
    refute html =~ "flash-progress"
  end

  test "renders flash_group with fixed positioning and high z-index above navbar" do
    html = render_component(&BackendWeb.Layouts.flash_group/1, flash: %{"info" => "Z-index test"})
    assert html =~ "tw-fixed"
    assert html =~ "tw-top-[4.75rem]"
    assert html =~ "tw-right-4"
    assert html =~ "tw-z-50"
    assert html =~ "phx-hook=\"FlashGroup\""
  end

  test "client-error and server-error flashes are initially hidden on page load in flash_group" do
    html = render_component(&BackendWeb.Layouts.flash_group/1, flash: %{})

    assert html =~ ~r/id="client-error"[^>]*hidden/
    assert html =~ ~r/id="client-error"[^>]*class="[^"]*tw-hidden[^"]*"/
    assert html =~ ~r/id="client-error"[^>]*style="[^"]*display:\s*none;[^"]*"/

    assert html =~ ~r/id="server-error"[^>]*hidden/
    assert html =~ ~r/id="server-error"[^>]*class="[^"]*tw-hidden[^"]*"/
    assert html =~ ~r/id="server-error"[^>]*style="[^"]*display:\s*none;[^"]*"/

    refute html =~ ~r/id="client-error"[^>]*class="[^"]*tw-flex[^"]*"/
    refute html =~ ~r/id="server-error"[^>]*class="[^"]*tw-flex[^"]*"/
  end
end
