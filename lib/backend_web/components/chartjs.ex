defmodule Components.ChartJS do
  use BackendWeb, :surface_live_component
  # use Phoenix.LiveComponent

  @moduledoc """
  Phoenix LiveComponent for rendering Chart.js charts with real-time updates.

  This component provides a reactive Chart.js integration that automatically updates
  when data changes and supports real-time data additions via `push_event`.

  ## Required Assigns

  - `:id` - Unique identifier for the chart component
  - `:config` - Chart.js configuration map (must include `:type`)
  - `:data` - Chart data map with `"labels"` and `"datasets"`

  ## Optional Assigns

  - `:height` - Chart height (default: `"400px"`)
  - `:width` - Chart width (default: `"100%"`)

  ## Basic Usage

      <Components.ChartJS
        id="sales_chart"
        config={%{type: "bar"}}
        data={%{
          "labels" => ["Jan", "Feb", "Mar"],
          "datasets" => [%{
            "label" => "Sales",
            "data" => [100, 150, 200],
            "backgroundColor" => "#3b82f6"
          }]
        }}
        height="400px"
        width="100%"
      />

  ## Chart Types

  Supported chart types in the `:config` map:

  - `%{type: "bar"}` - Bar chart
  - `%{type: "line"}` - Line chart
  - `%{type: "pie"}` - Pie chart
  - `%{type: "doughnut"}` - Doughnut chart
  - `%{type: "radar"}` - Radar chart
  - `%{type: "polarArea"}` - Polar area chart
  - `%{type: "bubble"}` - Bubble chart
  - `%{type: "scatter"}` - Scatter plot

  ## Advanced Configuration

      <Components.ChartJ.
        id="advanced_chart"
        config={%{
          type: "line",
          options: %{
            responsive: true,
            plugins: %{
              legend: %{position: "top"}
            },
            scales: %{
              y: %{beginAtZero: true}
            }
          }
        }}
        data={@chart_data}
        height="500px"
        width="100%"
      />

  ## Multiple Datasets

      data = %{
        "labels" => ["Q1", "Q2", "Q3", "Q4"],
        "datasets" => [
          %{
            "label" => "Revenue",
            "data" => [1000, 1200, 1500, 1300],
            "backgroundColor" => "#3b82f6"
          },
          %{
            "label" => "Profit",
            "data" => [200, 250, 400, 350],
            "backgroundColor" => "#ef4444"
          }
        ]
      }

  ## Real-time Updates

  Add data points dynamically using `push_event`:

      # Add data to all charts
      push_event(socket, "add_chart_data", %{
        "label" => "Apr",
        "datasets" => [%{"data" => 180}]
      })

      # Add data to specific chart
      push_event(socket, "add_chart_data", %{
        "target" => "sales_chart",
        "label" => "Apr",
        "datasets" => [%{"data" => 180}]
      })

      # Add data to multiple datasets
      push_event(socket, "add_chart_data", %{
        "label" => "Apr",
        "datasets" => [
          %{"datasetIndex" => 0, "data" => 1400},
          %{"datasetIndex" => 1, "data" => 380}
        ]
      })

  ## Multiple Charts

  Each chart component must have a unique `:id`:

      <.live_component module={ChartJs.ChartComponent} id="chart_1" ... />
      <.live_component module={ChartJs.ChartComponent} id="chart_2" ... />

  Use the `target` parameter to update specific charts:

      push_event(socket, "add_chart_data", %{...}, target: "chart_1")
  """

  @impl true
  def render(assigns) do
    ~F"""
    <div
      id={@id}
      phx-hook="ChartJs"
      data-config={Jason.encode!(@config)}
      data-data={Jason.encode!(@data)}
      style={"position: relative; height: #{@height}; width: #{@width};"}
    >
      <canvas id={@id <> "_canvas"}></canvas>
    </div>
    """
  end
end
