defmodule BackendWeb.ViewHelpers do
  @moduledoc false
  use Phoenix.View,
    root: "lib/backend_web/templates",
    namespace: BackendWeb

  defmacro __using__(_opts) do
    quote do
      import BackendWeb.AuthUtils
      import Components.Helper, only: [country_flag: 2]
      alias Components.Helper

      def render_datetime(datetime) do
        Helper.datetime(%{datetime: datetime})
      end

      def render_dropdown(options, title) do
        Helper.dropdown(%{options: options, title: title})
      end

      def render_dropdowns(dropdowns) do
        Helper.dropdowns(%{dropdowns: dropdowns})
      end

      def render_multiselect_dropdown(o = %{form: _, title: _, options: options, attr: attr}) do
        search_id = o |> Map.get(:search_id)

        search_class = "#{attr}_#{search_id}"
        checkbox_class = "#{attr}_#{search_id}_checkbox"

        assigns =
          o
          |> Map.put(:show_search, !!search_id)
          |> Map.put(:search_class, search_class)
          |> Map.put(:checkbox_class, checkbox_class)

        Helper.multiselect_dropdown(assigns)
      end

      def render_deckcode(<<deckcode::binary>>, hide_no_js \\ true) do
        Helper.deckcode(%{deckcode: deckcode, hide_no_js: hide_no_js})
      end

      def render_comparison(current, prev, flip, diff_format_fun \\ & &1)
      def render_comparison(current, nil, _, _), do: current
      def render_comparison(current, prev, _, _) when current == prev, do: current

      def render_comparison(current, prev, flip, dff) do
        {class, arrow} =
          if (current || 0) > (prev || 0) == flip,
            do: {"has-text-danger", "↓"},
            else: {"has-text-success", "↑"}

        diff = abs((current || 0) - prev)

        Helper.comparison(%{
          class: class,
          diff: dff.(diff),
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

      def render_legend_rank(rank)
          when (is_integer(rank) and rank > 0) or (is_binary(rank) and bit_size(rank) > 0) do
        Helper.legend_rank(%{rank: rank})
      end

      def render_legend_rank(rank), do: ""

      def render_game_type(type) do
        Helper.game_type(%{type: type})
      end

      def render_player_icon(name) do
        Helper.render_player_icon(name)
      end

      def render_player_name(name, with_country \\ false) do
        Helper.player_name(name, with_country)
      end

      def render_player_link(name, link \\ nil, with_country \\ false) do
        Helper.player_link(%{name: name, link: link, with_country: with_country})
      end

      def warning_triangle(), do: Helper.warning_triangle()
    end
  end
end
