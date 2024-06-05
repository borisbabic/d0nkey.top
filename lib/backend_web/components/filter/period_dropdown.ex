defmodule Components.Filter.PeriodDropdown do
  use Surface.LiveComponent
  alias Components.LivePatchDropdown
  alias Hearthstone.DeckTracker
  prop(title, :string, default: "Period")
  prop(param, :string, default: "period")
  prop(url_params, :map, from_context: {Components.LivePatchDropdown, :url_params})
  prop(path_params, :map, from_context: {Components.LivePatchDropdown, :path_params})
  prop(selected_params, :map, from_context: {Components.LivePatchDropdown, :selected_params})
  prop(filter_context, :atom, default: :public)
  prop(live_view, :module, required: true)
  prop(aggregated_only, :boolean, default: false)

  def render(assigns) do
    ~F"""
      <LivePatchDropdown
        options={options(@filter_context, @aggregated_only)}
        title={@title}
        param={@param}
        url_params={@url_params}
        path_params={@path_params}
        selected_params={@selected_params}
        live_view={@live_view} />
    """
  end

  def options(context, aggregated_only \\ false) do
    aggregated =
      DeckTracker.get_latest_agg_log_entry()
      |> Map.get(:periods, []) || []

    for %{slug: slug, display: d} <- periods(context),
        !aggregated_only or slug in aggregated do
      display =
        if slug in aggregated or context == :personal,
          do: d,
          else: Components.Helper.warning_triangle(%{before: d})

      {slug, display}
    end
  end

  defp periods(context) do
    DeckTracker.periods_for_filters(context)
    |> Enum.reject(&future?/1)
  end

  defp future?(%{period_start: %NaiveDateTime{} = period_start}) do
    NaiveDateTime.compare(period_start, NaiveDateTime.utc_now()) == :gt
  end

  defp future?(_), do: false

  @default_format 2
  def default(
        context \\ :public,
        format_or_criteria \\ @default_format,
        fallback_format \\ @default_format
      )

  def default(context, format_or_criteria, fallback_format) do
    format = extract_format(format_or_criteria, fallback_format || @default_format)
    DeckTracker.default_period(format)
  end

  def extract_format(format, fallback \\ @default_format)
  def extract_format(format, _fallback) when is_integer(format), do: format
  def extract_format(%{"format" => format}, fallback), do: Util.to_int(format, fallback)
  def extract_format(%{format: format}, fallback), do: Util.to_int(format, fallback)

  def extract_format(list, fallback) when is_list(list) do
    with nil <- List.keyfind(list, "format", 0),
         nil <- List.keyfind(list, :format, 0) do
      nil
    else
      {_, value} -> Util.to_int(value, fallback)
      _ -> nil
    end
  end

  def extract_format(format, fallback) when is_binary(format), do: Util.to_int(format, fallback)
  def extract_format(_, fallback), do: fallback
end
