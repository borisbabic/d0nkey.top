defmodule BackendWeb.ViewHelpers do
  @moduledoc false
  use Phoenix.View,
    root: "lib/backend_web/templates",
    namespace: BackendWeb

  defmacro __using__(_opts) do
    quote do
      def render_datetime(datetime) do
        render(BackendWeb.SharedView, "datetime.html", %{datetime: datetime})
      end

      def render_dropdown(options, title) do
        render(BackendWeb.SharedView, "dropdown_links.html", %{options: options, title: title})
      end

      def render_dropdowns(dropdowns) do
        render(BackendWeb.SharedView, "multiple_dropdown_links.html", %{dropdowns: dropdowns})
      end

      defp sort_by_selected(options, false), do: options

      defp sort_by_selected(options, true),
        do: options |> Enum.sort_by(fn o -> o.selected end, :desc)

      def render_multiselect_dropdown(o = %{form: _, title: _, options: options, attr: attr}) do
        search_id = o |> Map.get(:search_id)

        defaults = %{
          top_buttons: true,
          bottom_buttons: true,
          selected_first: true
        }

        with_defaults =
          defaults
          |> Map.merge(o)

        sorted = sort_by_selected(options, with_defaults.selected_first)
        search_class = "#{attr}_#{search_id}"
        checkbox_class = "#{attr}_#{search_id}_checkbox"

        render(
          BackendWeb.SharedView,
          "multiselect_dropdown.html",
          with_defaults
          |> Map.put(:show_search, !!search_id)
          |> Map.put(:search_class, search_class)
          |> Map.put(:checkbox_class, checkbox_class)
          |> Map.put(:options, sorted)
        )
      end

      def render_deckcode(<<deckcode::binary>>, hide_no_js \\ true) do
        style = if(hide_no_js, do: "display: none;", else: "")

        render(BackendWeb.SharedView, "deckcode.html", %{
          deckcode: deckcode,
          style: style,
          id: Util.gen_html_id()
        })
      end

      def render_comparison(current, nil, _), do: current
      def render_comparison(current, prev, _) when current == prev, do: current

      def render_comparison(current, prev, flip) do
        {class, arrow} =
          if current > prev == flip, do: {"has-text-danger", "↓"}, else: {"has-text-success", "↑"}

        render(BackendWeb.SharedView, "comparison.html", %{
          class: class,
          diff: abs(current - prev),
          arrow: arrow,
          current: current
        })
      end

      def dropdown_title(options, <<default::binary>>) do
        selected_title =
          options
          |> Enum.find_value(fn o -> o.selected && o.display end)

        selected_title || default
      end

      def country_flag(country) do
        name = Util.get_country_name(country)

        render(BackendWeb.SharedView, "country_flag.html", %{country: country, country_name: name})
      end

      def countries_options(selected_countries) do
        countries_options =
          Backend.PlayerInfo.get_eligible_countries()
          |> Enum.map(fn cc ->
            %{
              selected: cc && cc in selected_countries,
              display: cc |> Util.get_country_name(),
              name: cc |> Util.get_country_name(),
              value: cc
            }
          end)
          |> Enum.sort_by(fn %{display: display} -> display end)
      end

      def render_countries_multiselect_dropdown(form, selected_countries, opts \\ %{}) do
        %{
          form: form,
          title: "Filter Countries",
          options: countries_options(selected_countries),
          attr: "country",
          placeholder: "Country",
          search_id: "country-select"
        }
        |> Map.merge(opts)
        |> render_multiselect_dropdown()
      end
    end
  end
end
