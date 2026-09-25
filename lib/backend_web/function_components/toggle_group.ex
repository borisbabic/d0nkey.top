defmodule FunctionComponents.ToggleGroup do
  @moduledoc """
  The pill-style segmented toggle buttons used across the decks page, deck sheets page, and
  deckviewer page for view-mode / card-mode style switches (Grid vs Table, Card Top vs Cropped
  Card, Vertical vs Horizontal, etc).
  """

  use BackendWeb, :component

  attr :class, :string, default: ""
  slot :inner_block, required: true

  def group(assigns) do
    ~H"""
    <div class={["tw-flex tw-items-center", @class]}>
      <div class="buttons has-addons tw-mb-0">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  @doc """
  A single pill option. Pass either `patch` (a URL to patch to, for state kept in query
  params) or `click` (a phx-click event name, optionally with `target`, for state kept in a
  LiveView/LiveComponent assign).
  """
  attr :patch, :string, default: nil
  attr :click, :string, default: nil
  attr :target, :any, default: nil
  attr :active, :boolean, required: true
  attr :title, :string, default: nil
  slot :icon, required: true
  slot :inner_block, required: true

  def option(assigns) do
    ~H"""
    <.link :if={@patch} patch={@patch} title={@title} class={option_class(@active)}>
      <span class="icon is-small">{render_slot(@icon)}</span>
      <span>{render_slot(@inner_block)}</span>
    </.link>
    <button :if={!@patch} type="button" phx-click={@click} phx-target={@target} title={@title} class={option_class(@active)}>
      <span class="icon is-small">{render_slot(@icon)}</span>
      <span>{render_slot(@inner_block)}</span>
    </button>
    """
  end

  defp option_class(active),
    do: [
      "button is-small tw-inline-flex tw-items-center tw-gap-1.5",
      if(active, do: "is-info is-selected", else: "is-dark")
    ]

  slot :inner_block, required: true

  defp icon_svg(assigns) do
    ~H"""
    <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
      {render_slot(@inner_block)}
    </svg>
    """
  end

  def grid_icon(assigns) do
    ~H"""
    <.icon_svg>
      <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6A2.25 2.25 0 0 1 6 3.75h2.25A2.25 2.25 0 0 1 10.5 6v2.25a2.25 2.25 0 0 1-2.25 2.25H6a2.25 2.25 0 0 1-2.25-2.25V6ZM3.75 15.75A2.25 2.25 0 0 1 6 13.5h2.25a2.25 2.25 0 0 1 2.25 2.25V18a2.25 2.25 0 0 1-2.25 2.25H6A2.25 2.25 0 0 1 3.75 18v-2.25ZM13.5 6a2.25 2.25 0 0 1 2.25-2.25H18A2.25 2.25 0 0 1 20.25 6v2.25A2.25 2.25 0 0 1 18 10.5h-2.25a2.25 2.25 0 0 1-2.25-2.25V6ZM13.5 15.75a2.25 2.25 0 0 1 2.25-2.25H18a2.25 2.25 0 0 1 2.25 2.25V18A2.25 2.25 0 0 1 18 20.25h-2.25A2.25 2.25 0 0 1 13.5 18v-2.25Z" />
    </.icon_svg>
    """
  end

  def table_icon(assigns) do
    ~H"""
    <.icon_svg>
      <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
    </.icon_svg>
    """
  end

  def card_top_icon(assigns) do
    ~H"""
    <.icon_svg>
      <path stroke-linecap="round" stroke-linejoin="round" d="M6 3h12a2 2 0 012 2v14a2 2 0 01-2 2H6a2 2 0 01-2-2V5a2 2 0 012-2z" />
      <path stroke-linecap="round" stroke-linejoin="round" d="M6 10h12" />
    </.icon_svg>
    """
  end

  def cropped_icon(assigns) do
    ~H"""
    <.icon_svg>
      <path stroke-linecap="round" stroke-linejoin="round" d="M4 4h16v16H4V4z" />
      <path stroke-linecap="round" stroke-linejoin="round" d="M4 14l5-5 4 4 3-3 4 4" />
    </.icon_svg>
    """
  end

  def rotate_icon(assigns) do
    ~H"""
    <.icon_svg>
      <path stroke-linecap="round" stroke-linejoin="round" d="M16.023 9.348h4.992v-4.992M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182m0-4.991v4.99" />
    </.icon_svg>
    """
  end

  def compare_icon(assigns) do
    ~H"""
    <.icon_svg>
      <path stroke-linecap="round" stroke-linejoin="round" d="M7.5 21 3 16.5m0 0L7.5 12M3 16.5h18M16.5 3 21 7.5m0 0L16.5 12M21 7.5H3" />
    </.icon_svg>
    """
  end

  def sort_icon(assigns) do
    ~H"""
    <.icon_svg>
      <path stroke-linecap="round" stroke-linejoin="round" d="M3 7.5 7.5 3m0 0L12 7.5M7.5 3v13.5m13.5 0L16.5 21m0 0L12 16.5m4.5 4.5V7.5" />
    </.icon_svg>
    """
  end

  def chart_icon(assigns) do
    ~H"""
    <.icon_svg>
      <path stroke-linecap="round" stroke-linejoin="round" d="M4 21V10M12 21V4M20 21v-7" />
    </.icon_svg>
    """
  end
end
