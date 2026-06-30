defmodule FunctionComponents.Table do
  @moduledoc "table components"
  use Phoenix.Component

  slot :inner_block, required: true
  attr :id, :string, required: false

  def table(assigns) do
    ~H"""
    <div id={@id} class="tw-overflow-x-auto tw-rounded-xl tw-border tw-border-slate-800 has-background-dark">
      <table class="tw-w-full tw-text-left tw-border-collapse">
        {render_slot(@inner_block)}
      </table>
    </div>
    """
  end

  slot :inner_block, required: true

  def thead(assigns) do
    ~H"""
    <thead>
      {render_slot(@inner_block)}
    </thead>
    """
  end

  slot :inner_block, required: true

  def tbody(assigns) do
    ~H"""
    <tbody class="tw-divide-y tw-divide-slate-800/50">
      {render_slot(@inner_block)}
    </tbody>
    """
  end

  slot :inner_block, required: true
  attr :header, :boolean, required: true
  attr :class, :string, required: false, default: ""
  attr :selected, :boolean, default: false

  def tr(assigns) do
    ~H"""
    <tr class={[tr_class(@header), selected_class(@selected), @class]}>
      {render_slot(@inner_block)}
    </tr>
    """
  end

  defp selected_class(true), do: "tw-bg-[#24292e] hover:tw-bg-slate-700/40"
  defp selected_class(_), do: ""
  defp tr_class(true), do: "tw-border-b tw-border-slate-800 tw-bg-black/20"
  defp tr_class(false), do: "tw-transition-colors hover:tw-bg-slate-800/30"

  slot :inner_block, required: true
  attr :class, :string, required: false, default: ""

  def trh(assigns) do
    ~H"""
    <.tr header={true} class={@class}>
      {render_slot(@inner_block)}
    </.tr>
    """
  end

  slot :inner_block, required: true
  attr :class, :string, required: false, default: ""
  attr :selected, :boolean, default: false

  def trb(assigns) do
    ~H"""
    <.tr header={false} class={@class} selected={@selected}>
      {render_slot(@inner_block)}
    </.tr>
    """
  end

  slot :inner_block, required: true
  attr :class, :string, required: false, default: ""

  def td(assigns) do
    ~H"""
    <td class={["tw-p-3 tw-align-middle tw-font-medium", @class]}>
      {render_slot(@inner_block)}
    </td>
    """
  end

  slot :inner_block, required: true
  attr :class, :string, required: false, default: ""

  def th(assigns) do
    ~H"""
    <th class={["tw-p-4 tw-text-xs tw-font-bold tw-uppercase tw-tracking-wider hover:tw-text-white", @class]}>
      {render_slot(@inner_block)}
    </th>
    """
  end
end
