defmodule BackendWeb.Components.MatchupsTableTest do
  use BackendWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias Components.MatchupsTable

  @sample_matchups [
    %{
      archetype: :frost_death_knight,
      total_stats: %{winrate: 55.0, games: 100},
      opponent_stats: %{
        frost_death_knight: %{winrate: 50.0, games: 20},
        control_warrior: %{winrate: 60.0, games: 80}
      }
    },
    %{
      archetype: :control_warrior,
      total_stats: %{winrate: 45.0, games: 100},
      opponent_stats: %{
        frost_death_knight: %{winrate: 40.0, games: 80},
        control_warrior: %{winrate: 50.0, games: 20}
      }
    }
  ]

  defp render_table(opts) do
    defaults = [
      id: "matchups_table",
      matchups: @sample_matchups,
      min_matchup_sample: 1,
      min_archetype_sample: 1,
      weight_merging_map: %{},
      win_loss: false
    ]

    assigns = Keyword.merge(defaults, opts)
    render_component(MatchupsTable, assigns)
  end

  defp build_socket(assigns) do
    %Phoenix.LiveView.Socket{}
    |> Phoenix.Component.assign(assigns)
  end

  describe "rendering" do
    test "renders input elements for custom matchup weights" do
      html = render_table([])
      assert html =~ "id=\"custom_weight_input_frost_death_knight\""
      assert html =~ "id=\"custom_weight_input_control_warrior\""
      assert html =~ "Reset Weights"
      assert html =~ "Seed Weights"
    end
  end

  describe "handle_event reset_weights" do
    test "clears custom_matchup_weights assign and pushes clear event with selector" do
      socket = build_socket(custom_matchup_weights: %{"frost_death_knight" => 10, "control_warrior" => 5})

      assert {:noreply, socket} = MatchupsTable.handle_event("reset_weights", %{}, socket)
      assert socket.assigns.custom_matchup_weights == %{}

      assert [
               [
                 "clear",
                 %{
                   key: "matchups_table_custom_weights",
                   clear_selector: "input[id^='custom_weight_input_']"
                 }
               ]
             ] = socket.private[:push_events] || socket.private[:live_temp][:push_events]
    end
  end

  describe "handle_event update_custom_matchup_weights" do
    test "updates a specific matchup weight" do
      socket = build_socket(custom_matchup_weights: %{"control_warrior" => 5})

      params = %{
        "_target" => ["frost_death_knight"],
        "frost_death_knight" => "12"
      }

      assert {:noreply, socket} =
               MatchupsTable.handle_event("update_custom_matchup_weights", params, socket)

      assert socket.assigns.custom_matchup_weights == %{
               "control_warrior" => 5,
               "frost_death_knight" => 12
             }

      events = socket.private[:push_events] || socket.private[:live_temp][:push_events]
      assert [["store", %{key: "matchups_table_custom_weights", data: stored_data}]] = events

      assert Jason.decode!(stored_data) == %{
               "control_warrior" => 5,
               "frost_death_knight" => 12
             }
    end

    test "deletes weight when empty string is provided" do
      socket = build_socket(custom_matchup_weights: %{"frost_death_knight" => 10, "control_warrior" => 5})

      params = %{
        "_target" => ["frost_death_knight"],
        "frost_death_knight" => ""
      }

      assert {:noreply, socket} =
               MatchupsTable.handle_event("update_custom_matchup_weights", params, socket)

      assert socket.assigns.custom_matchup_weights == %{"control_warrior" => 5}
    end
  end

  describe "handle_event seed_weights" do
    test "seeds custom weights calculated from popularity" do
      socket = build_socket(matchups: @sample_matchups, custom_matchup_weights: %{})

      assert {:noreply, socket} =
               MatchupsTable.handle_event("seed_weights", %{"total_games" => "200"}, socket)

      assert socket.assigns.custom_matchup_weights == %{
               "frost_death_knight" => 500,
               "control_warrior" => 500
             }
    end
  end

  describe "handle_event set_custom_weights" do
    test "decodes JSON string and assigns custom_matchup_weights" do
      socket = build_socket(custom_matchup_weights: %{})

      json_weights = Jason.encode!(%{"frost_death_knight" => 8})

      assert {:noreply, socket} =
               MatchupsTable.handle_event("set_custom_weights", json_weights, socket)

      assert socket.assigns.custom_matchup_weights == %{"frost_death_knight" => 8}
    end
  end

  describe "deck archetype navigation in MatchupsTable" do
    test "renders direct link when archetype has only 1 deck archetype" do
      html = render_table(deck_archetype_mapping: %{})
      assert html =~ ~s(href="/archetype/frost_death_knight")
      assert html =~ ~s(href="/archetype/control_warrior")
      refute html =~ ~s(phx-click="choose_deck_archetype")
    end

    test "renders button with chevron when archetype has multiple deck archetypes" do
      custom_mapping = %{"Frost Aggro" => "frost_death_knight"}
      html = render_table(deck_archetype_mapping: custom_mapping)

      assert html =~ ~s(phx-click="choose_deck_archetype")
      assert html =~ ~s(phx-value-archetype="frost_death_knight")
      refute html =~ ~s(href="/archetype/frost_death_knight")
      # control_warrior has no mappings so it still has direct link
      assert html =~ ~s(href="/archetype/control_warrior")
    end

    test "renders direct link when player_perspective is deck_archetype" do
      custom_mapping = %{"Frost Aggro" => "frost_death_knight"}

      html =
        render_table(
          player_perspective: "deck_archetype",
          deck_archetype_mapping: custom_mapping
        )

      assert html =~ ~s(href="/archetype/frost_death_knight")
      refute html =~ ~s(phx-click="choose_deck_archetype")
    end

    test "does not render deck archetype link when player_perspective is class" do
      html = render_table(player_perspective: "class", deck_archetype_mapping: %{})
      refute html =~ ~s(href="/archetype/frost_death_knight")
      refute html =~ ~s(phx-click="choose_deck_archetype")
    end

    test "choose_deck_archetype event assigns selected_archetype_choices and renders modal" do
      custom_mapping = %{"Frost Aggro" => "frost_death_knight"}

      socket =
        build_socket(
          matchups: @sample_matchups,
          deck_archetype_mapping: custom_mapping
        )

      assert {:noreply, updated_socket} =
               MatchupsTable.handle_event(
                 "choose_deck_archetype",
                 %{"archetype" => "frost_death_knight"},
                 socket
               )

      assert %{
               archetype: "frost_death_knight",
               deck_archetypes: ["frost_death_knight", "Frost Aggro"]
             } = updated_socket.assigns.selected_archetype_choices

      # Modal renders with options
      modal_html =
        render_table(
          deck_archetype_mapping: custom_mapping,
          selected_archetype_choices: updated_socket.assigns.selected_archetype_choices
        )

      assert modal_html =~ "Choose Deck Archetype"
      assert modal_html =~ ~s(href="/archetype/frost_death_knight")
      assert modal_html =~ ~s(href="/archetype/Frost%20Aggro")
      assert modal_html =~ "class-background"
      assert modal_html =~ "basic-black-text"
    end

    test "close_deck_archetype_modal event resets selected_archetype_choices" do
      socket =
        build_socket(
          selected_archetype_choices: %{
            archetype: "frost_death_knight",
            deck_archetypes: ["frost_death_knight", "Frost Aggro"]
          }
        )

      assert {:noreply, updated_socket} =
               MatchupsTable.handle_event("close_deck_archetype_modal", %{}, socket)

      assert updated_socket.assigns.selected_archetype_choices == nil
    end

    test "choose_deck_archetype with single archetype navigates directly" do
      socket =
        build_socket(
          matchups: @sample_matchups,
          deck_archetype_mapping: %{}
        )

      assert {:noreply, updated_socket} =
               MatchupsTable.handle_event(
                 "choose_deck_archetype",
                 %{"archetype" => "frost_death_knight"},
                 socket
               )

      assert updated_socket.redirected == {:live, :redirect, %{to: "/archetype/frost_death_knight", kind: :push}}
    end
  end
end
