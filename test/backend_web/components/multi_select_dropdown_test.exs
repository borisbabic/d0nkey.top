defmodule BackendWeb.Components.MultiSelectDropdownTest do
  use BackendWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias Components.MultiSelectDropdown
  alias Components.Filter.ArchetypeSelect
  alias Components.Filter.ClassMultiDropdown

  defp render_ms(opts) do
    defaults = [
      id: "ms_test",
      options: [],
      param: "class",
      title: "Title",
      class: nil,
      warning: false,
      show_search: true,
      search_event: %{name: "search"},
      selected_to_top: true,
      matches_search: & &1,
      normalizer: &Util.id/1,
      num_to_show: 7,
      any_as_empty: true,
      select_all: false,
      scrollable: false,
      selected: [],
      search: "",
      current: []
    ]

    assigns = Keyword.merge(defaults, opts)
    render_component(MultiSelectDropdown, assigns)
  end

  defp render_archetype_select(opts) do
    defaults = [
      id: "arch_test",
      param: "archetype",
      title: "Select Archetype",
      search: "",
      selected: [],
      selectable_archetypes: [],
      updater: &MultiSelectDropdown.update_selected/2,
      criteria: %{},
      played_cards_archetypes: false,
      select_all: true,
      scrollable: true,
      class: nil,
      warning: false,
      show_search: true,
      search_event: %{name: "search"},
      selected_to_top: true,
      matches_search: & &1,
      normalizer: &Util.id/1,
      num_to_show: 7,
      any_as_empty: true,
      current: []
    ]

    assigns = Keyword.merge(defaults, opts)
    render_component(ArchetypeSelect, assigns)
  end

  defp render_class_multi(opts) do
    defaults = [
      id: "class_test",
      title: "Class",
      param: "class",
      any_name: "Any Class",
      name_prefix: "",
      url_params: %{},
      path_params: nil,
      selected_params: nil,
      include_neutral: false,
      options: nil,
      select_all: true,
      live_view: BackendWeb.DecksLive,
      class: nil,
      warning: false,
      show_search: false,
      search_event: %{name: "search"},
      selected_to_top: false,
      matches_search: & &1,
      normalizer: &Util.id/1,
      num_to_show: 20,
      any_as_empty: true,
      scrollable: false,
      selected: [],
      search: "",
      current: []
    ]

    assigns = Keyword.merge(defaults, opts)
    render_component(ClassMultiDropdown, assigns)
  end

  describe "MultiSelectDropdown - Select All" do
    test "renders Select All button when select_all is true" do
      html =
        render_ms(
          options: ["Mage", "Hunter", "Paladin"],
          select_all: true
        )

      assert html =~ "Select All"
      assert html =~ "ms_test_select_all_btn"
    end

    test "does not render Select All button when select_all is false" do
      html =
        render_ms(
          options: ["Mage", "Hunter", "Paladin"],
          select_all: false
        )

      refute html =~ "Select All"
    end

    test "handle_event select_all selects all matching options when search is empty" do
      dummy_socket = %Phoenix.LiveView.Socket{
        assigns: %{
          options: ["Mage", "Hunter", "Paladin"],
          updater: fn _socket, selected -> {:updated, selected} end,
          normalizer: &Util.id/1,
          current: [],
          search: "",
          any_as_empty: true
        }
      }

      assert {:noreply, {:updated, ["Mage", "Hunter", "Paladin"]}} =
               MultiSelectDropdown.handle_event("select_all", %{}, dummy_socket)
    end

    test "handle_event select_all selects only options matching search" do
      dummy_socket = %Phoenix.LiveView.Socket{
        assigns: %{
          options: ["Mage", "Hunter", "Paladin"],
          updater: fn _socket, selected -> {:updated, selected} end,
          normalizer: &Util.id/1,
          current: ["Hunter"],
          search: "Mag",
          any_as_empty: true
        }
      }

      assert {:noreply, {:updated, selected}} =
               MultiSelectDropdown.handle_event("select_all", %{}, dummy_socket)

      assert "Mage" in selected
      assert "Hunter" in selected
      refute "Paladin" in selected
    end
  end

  describe "MultiSelectDropdown - Scrollable" do
    test "renders scrollable wrapper when scrollable is true" do
      html =
        render_ms(
          options: ["Mage", "Hunter", "Paladin"],
          scrollable: true
        )

      assert html =~ "tw-max-h-60 tw-overflow-y-auto"
    end

    test "does not render scrollable wrapper class when scrollable is false" do
      html =
        render_ms(
          options: ["Mage", "Hunter", "Paladin"],
          scrollable: false
        )

      refute html =~ "tw-max-h-60 tw-overflow-y-auto"
    end
  end

  describe "ArchetypeSelect integration" do
    test "enables select_all and scrollable by default" do
      html =
        render_archetype_select(selectable_archetypes: ["Pure Paladin", "Secret Mage", "Face Hunter"])

      assert html =~ "Select All"
      assert html =~ "tw-max-h-60 tw-overflow-y-auto"
    end
  end

  describe "ClassMultiDropdown integration" do
    test "enables select_all by default" do
      html = render_class_multi([])

      assert html =~ "Select All"
    end
  end
end
