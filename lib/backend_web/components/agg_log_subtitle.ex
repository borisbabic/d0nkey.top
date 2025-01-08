defmodule Components.AggLogSubtitle do
  @moduledoc false
  use BackendWeb, :surface_component

  prop(latest_agg, :any, default: :none)

  def render(%{latest_agg: :none} = assigns) do
    inserted_at =
      case Hearthstone.DeckTracker.get_latest_agg_log_entry() do
        %{inserted_at: %NaiveDateTime{} = inserted_at} -> inserted_at
        _ -> nil
      end

    assigns
    |> assign(latest_agg: inserted_at)
    |> render()
  end

  def render(%{latest_agg: %NaiveDateTime{}} = assigns) do
    ~F"""
    <span phx-update="ignore">| {Timex.from_now(@latest_agg)} </span>
    """
  end

  def render(assigns) do
    ~F"""
    <span class="empty_agg_log_subtitle"></span>
    """
  end
end
