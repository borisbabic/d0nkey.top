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
                   selector: "input[id^='custom_weight_input_']"
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
end
