defmodule Components.Filter.Context do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      @context_base Components.LivePatchDropdown
      prop(live_view, :any, required: true, from_context: {@context_base, :live_view})
      prop(path_params, :struct, from_context: {@context_base, :path_params})
      prop(url_params, :map, required: true, from_context: {@context_base, :url_params})

      def url_params(socket) do
        socket
        |> Surface.Components.Context.get(@context_base, :url_params)
      end

      def path_params(socket) do
        socket
        |> Surface.Components.Context.get(@context_base, :path_params)
      end

      def selected_params(socket) do
        socket
        |> Surface.Components.Context.get(@context_base, :selected_params)
      end

      def live_view(socket) do
        socket
        |> Surface.Components.Context.get(@context_base, :live_view)
      end

      @doc """
      Useful to avoid repetition when using multiple livepatch dropdown, ex:
      ```
      def update(assigns, socket) do
        selected = calculate_selected(assigns)
        {
          :ok,
          socket
          |> assign(assigns)
          |> LivePatchDropdown.update_context(assigns.live_view, assigns.url_params, assigns.path_params, selected)
        }
      end
      ```
      """
      def update_context(
            socket,
            live_view,
            url_params,
            path_params \\ nil,
            selected_params \\ nil
          ) do
        context = [
          url_params: url_params,
          path_params: path_params,
          selected_params: selected_params,
          live_view: live_view
        ]

        socket
        |> Surface.Components.Context.put(@context_base, context)
      end
    end
  end
end
