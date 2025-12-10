defmodule Components.AggLogSubtitle do
  @moduledoc false
  use BackendWeb, :surface_component

  prop(latest_agg, :any, default: :none)
  prop(criteria, :any, default: nil)
  prop(format, :any, default: nil)
  prop(period, :string, default: nil)

  def render(%{latest_agg: %NaiveDateTime{}} = assigns) do
    ~F"""
    <span>| {Timex.from_now(@latest_agg)} </span>
    """
  end

  def render(%{format: format, period: period} = assigns)
      when not is_nil(format) and not is_nil(period) do
    Hearthstone.DeckTracker.aggregated_stats_table_name(period, format)
    |> do_render_partitioned(assigns)
  end

  def render(%{criteria: criteria} = assigns) when not is_nil(criteria) do
    case Hearthstone.DeckTracker.partitioned_agg_table_name(criteria) do
      {:ok, name} -> do_render_partitioned(name, assigns)
      _ -> empty(%{})
    end
  end

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

  def render(assigns) do
    empty(assigns)
  end

  defp empty(assigns) do
    ~F"""
    <span class="empty_agg_log_subtitle"></span>
    """
  end

  defp do_render_partitioned(table_name, assigns) do
    with {:ok, comment} <- Backend.Repo.table_comment(table_name),
         {:ok, inserted_at} <- NaiveDateTime.from_iso8601(comment) do
      assigns
      |> assign(latest_agg: inserted_at)
      |> render()
    else
      _ -> empty(%{})
    end
  end
end
