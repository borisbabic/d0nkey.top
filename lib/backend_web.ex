defmodule BackendWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use BackendWeb, :controller
      use BackendWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: BackendWeb

      import Plug.Conn
      import BackendWeb.Gettext
      import Phoenix.LiveView.Controller
      alias BackendWeb.Router.Helpers, as: Routes

      def multi_select_to_array(multi = %{}) do
        multi
        |> Enum.filter(fn {_, selected} -> selected == "true" end)
        |> Enum.map(fn {column, _} -> column end)
      end

      def multi_select_to_array(multi), do: []
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def view do
    quote do
      use Phoenix.View,
        root: "lib/backend_web/templates",
        namespace: BackendWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      def render_datetime(datetime) do
        render(BackendWeb.SharedView, "datetime.html", %{datetime: datetime})
      end

      def render_dropdown(options, title) do
        render(BackendWeb.SharedView, "dropdown_links.html", %{options: options, title: title})
      end

      def render_dropdowns(dropdowns) do
        render(BackendWeb.SharedView, "multiple_dropdown_links.html", %{dropdowns: dropdowns})
      end

      def render_deckcode(<<deckcode::binary>>) do
        render(BackendWeb.SharedView, "deckcode.html", %{
          deckcode: deckcode,
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

      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {BackendWeb.LayoutView, "live.html"}

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import BackendWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView helpers (live_render, live_component, live_patch, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import BackendWeb.ErrorHelpers
      import BackendWeb.Gettext
      alias BackendWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
