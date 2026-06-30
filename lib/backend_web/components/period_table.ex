defmodule Components.PeriodTable do
  @moduledoc false
  use BackendWeb, :surface_component
  alias Components.Helper
  alias Hearthstone.DeckTracker.Period

  prop(periods, :list, required: true)
  prop(include_decks_link, :boolean, default: false)
  prop(include_meta_link, :boolean, default: false)

  def render(assigns) do
    ~F"""
    <.table id="period_table">
      <.thead>
        <.trh>
          <.th>Period</.th>
          <.th>Start</.th>
          <.th>End</.th>
          <.th :if={@include_decks_link}>Decks</.th>
          <.th :if={@include_meta_link}>Decks</.th>
        </.trh>
      </.thead>
      <.tbody>
        <.trb :for={%{display: display, start_time: start_time, end_time: end_time, slug: slug} <- periods(@periods)}>
          <.td>{display}</.td>
          <.td><Helper.datetime datetime={start_time}/></.td>
          <.td><Helper.datetime datetime={end_time}/></.td>
          <.td :if={@include_decks_link}>
            <a href={~p"/decks?period=#{slug}"}>Decks</a>
          </.td>
          <.td :if={@include_meta_link}>
            <a href={~p"/meta?period=#{slug}"}>Meta</a>
          </.td>
        </.trb>
      </.tbody>
    </.table>
    """
  end

  defp periods(periods) do
    for %{display: display, slug: slug} = p <- periods,
        {:ok, start_time} <- [Period.start_time(p)],
        {:ok, end_time} <- [Period.end_time_or_now(p)] do
      %{display: display, start_time: start_time, end_time: end_time, slug: slug}
    end
  end
end
