defmodule Components.Filter.PeriodDropdown do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.LivePatchDropdown
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Period

  prop(title, :string, default: "Period")
  prop(param, :string, default: "period")
  prop(url_params, :map, from_context: {Components.LivePatchDropdown, :url_params})
  prop(path_params, :map, from_context: {Components.LivePatchDropdown, :path_params})
  prop(selected_params, :map, from_context: {Components.LivePatchDropdown, :selected_params})
  prop(filter_context, :atom, default: :public)
  prop(live_view, :module, required: true)
  prop(aggregated_only, :boolean, default: false)
  prop(warning, :boolean, default: false)
  prop(format, :integer, default: nil)

  def render(assigns) do
    ~F"""
    <span>
      <LivePatchDropdown
        options={options(@filter_context, @aggregated_only, format(@format, @url_params))}
        title={@title}
        param={@param}
        url_params={@url_params}
        path_params={@path_params}
        warning={@warning}
        selected_params={@selected_params}
        live_view={@live_view} />
    </span>
    """
  end

  def options(context, aggregated_only, format) do
    aggregated_periods = DeckTracker.aggregated_periods_for_format(format)
    aggregated_slugs = Enum.map(aggregated_periods, & &1.slug)

    for %{slug: slug, display: d} <- periods(context, format),
        !aggregated_only or slug in aggregated_slugs do
      display =
        if slug in aggregated_slugs or context == :personal,
          do: d,
          else: Components.Helper.warning_triangle(%{before: d})

      {slug, display}
    end
  end

  defp periods(context, format) do
    DeckTracker.periods_for_filters(context, format)
    |> Enum.reject(&Period.future?/1)
  end

  @default_format 2
  def default(
        context \\ :public,
        format_or_criteria \\ @default_format,
        fallback_format \\ @default_format
      )

  def default(_context, format_or_criteria, fallback_format) do
    format = extract_format(format_or_criteria, fallback_format || @default_format)
    DeckTracker.default_period(format)
  end

  defp format(format, _params) when is_integer(format) or is_binary(format), do: format

  defp format(_format, params) do
    extract_format(params, @default_format)
  end

  defp extract_format(format, _fallback) when is_integer(format), do: format
  defp extract_format(%{"format" => format}, fallback), do: Util.to_int(format, fallback)
  defp extract_format(%{format: format}, fallback), do: Util.to_int(format, fallback)

  defp extract_format(list, fallback) when is_list(list) do
    with nil <- List.keyfind(list, "format", 0),
         nil <- List.keyfind(list, :format, 0) do
      nil
    else
      {_, value} -> Util.to_int(value, fallback)
      _ -> nil
    end
  end

  defp extract_format(format, fallback) when is_binary(format), do: Util.to_int(format, fallback)
  defp extract_format(_, fallback), do: fallback
end
