defmodule FunctionComponents.ChartJs do
  use BackendWeb, :component
  @moduledoc "Wrapper for chart.js"

  attr :id, :string, required: true
  attr :config, :map, default: %{}
  attr :data, :map, required: true
  attr :canvas_class, :string, default: "tw-bg-gray-300"

  def chart(assigns) do
    ~H"""
    <div
        id={@id}
        phx-hook="ChartJs"
        data-config={Jason.encode!(@config)}
        data-data={Jason.encode!(@data)} >
        <canvas class={@canvas_class} id={@id <> "_canvas"}></canvas>
      </div>
    """
  end

  for {fun, plot_type} <- [
        {:bar, :bar},
        {:line, :line},
        {:pie, :pie},
        {:doughnut, :doughnut},
        {:radar, :radar},
        {:polar_area, :polarArea},
        {:bubble, :bubble},
        {:scatter, :scatter}
      ] do
    attr :id, :string, required: true
    attr :config, :map, default: %{}
    attr :data, :map, required: true
    attr :canvas_class, :string, default: "tw-bg-gray-300"

    def unquote(fun)(assigns) do
      assigns
      |> update(:config, fn old -> Map.merge(old, %{type: unquote(plot_type)}) end)
      |> chart()
    end
  end
end
