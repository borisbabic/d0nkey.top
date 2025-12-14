defmodule BackendWeb.PlaygroundLive do
  use BackendWeb, :surface_live_view

  use Components.TwitchChat, component_ids: ["d0nkeytop_twitch_chat"]
  alias FunctionComponents.ChartJs

  data(user, :any)

  def mount(_params, session, socket) do
    {:ok, socket |> assign_defaults(session) |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <div>
        <TwitchChat id="d0nkeytop_twitch_chat" channel="#d0nkeytop" />
        <div class="title is-1">Chart</div>
        <ChartJs.scatter id="chart" data={data()}/>
      </div>
    """
  end

  defp data() do
    %{
      "labels" => ["A", "B"],
      "datasets" => [%{"data" => [%{"x" => 1, "y" => 2}, %{"x" => 3, "y" => 4}]}]
    }
  end

  # def labeled_scatter_plot(data) do
  #   # 1. Define the Point Mark (the scatter dots)
  #   points =
  #     data
  #     |> Tucan.new(mark: :point)
  #     |> Tucan.encode(:x, "x_value", type: :quantitative)
  #     |> Tucan.encode(:y, "y_value", type: :quantitative)
  #     |> Tucan.encode(:color, "category", type: :nominal) # Color by category

  #   # 2. Define the Text Mark (the labels)
  #   labels =
  #     data
  #     |> Tucan.new(mark: :text)
  #     |> Tucan.encode(:x, "x_value", type: :quantitative)
  #     |> Tucan.encode(:y, "y_value", type: :quantitative)
  #     # The key part: map the 'label' field to the text property
  #     |> Tucan.encode(:text, "label", type: :nominal)
  #     |> Tucan.encode(:color, :black) # Make the label text black
  #     |> Tucan.Text.set_align(:left)  # Position the text next to the point
  #     |> Tucan.Text.set_dx(5)         # Nudge the text 5 pixels to the right

  #   # 3. Combine them into a Layered Plot
  #   Tucan.LayeredPlot.new([points, labels])
  #   |> Tucan.set_title("Labeled Scatter Plot (Tucan)")
  # end

  # def plot() do
  #   # # Sample Data (a list of maps/structs where keys match field names)
  #   data =
  #     %{x_value: 10, y_value: 20, label: "A", category: "Group 1"},
  #     %{x_value: 35, y_value: 55, label: "B", category: "Group 2"},
  #     %{x_value: 70, y_value: 15, label: "C", category: "Group 1"},
  #     %{x_value: 90, y_value: 80, label: "D", category: "Group 2"}
  #   ]
  #   # # Function call
  #   plot = labeled_scatter_plot(data)
  #   # # You would then pass this 'plot' struct to your LiveView's Tucan component
  # end
end
