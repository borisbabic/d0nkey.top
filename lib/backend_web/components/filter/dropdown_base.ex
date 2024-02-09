defmodule Components.Filter.DropdownBase do
  defmacro __using__(opts) do
    current_is_list = Keyword.get(opts, :current_is_list, false)

    quote do
      alias BackendWeb.Router.Helpers, as: Routes
      @context_base Components.LivePatchDropdown
      # either a list of {value, display} tuples, or a list of one value when value == display
      prop(options, :list, required: true)
      prop(param, :string, required: true)
      prop(live_view, :any, required: true, from_context: {@context_base, :live_view})
      prop(path_params, :struct, from_context: {@context_base, :path_params})
      prop(url_params, :map, required: true, from_context: {@context_base, :url_params})
      prop(title, :string, required: false)

      # If the params we want to use to decide whether it's selected differ from the url params
      prop(selected_params, :any, from_context: {@context_base, :selected_params})
      prop(selected_as_title, :boolean, default: true)

      prop(current_val, :any, required: false)
      prop(normalizer, :fun, required: false, default: &Util.id/1)

      data(current, :any)
      data(actual_title, :any)

      def add_to_empty(assigns) do
        add_title_current(assigns)
      end

      defoverridable add_to_empty: 1

      def add_title_current(assigns) do
        current = current(assigns)
        title = title(assigns, current)
        Map.merge(assigns, %{current: current, actual_title: title})
      end

      def link(socket, live_view, nil, params) do
        Routes.live_path(socket, live_view, params)
      end

      def link(socket, live_view, path_params, params) do
        Routes.live_path(socket, live_view, path_params, params)
      end

      def update_params(url_params, param, nil), do: Map.delete(url_params, param)
      def update_params(url_params, param, val), do: Map.put(url_params, param, val)

      if unquote(current_is_list) do
        def apply_normalizer_to_current(current, normalizer) do
          Enum.map(current, fn v -> normalizer.(v) end)
        end

        def current?(value, current, normalizer) do
          normalized_value = normalizer.(value)
          normalized_current = apply_normalizer_to_current(current, normalizer)
          normalized_value in normalized_current
        end
      else
        def apply_normalizer_to_current(current, normalizer) do
          normalizer.(current)
        end

        def current?(value, current, normalizer) do
          apply_normalizer_to_current(current, normalizer) == normalizer.(value)
        end
      end

      def title(%{selected_as_title: false, title: title}, _), do: title

      def title(
            %{selected_as_title: true, title: title, options: options, normalizer: normalizer},
            current
          ) do
        Enum.find_value(options, title, fn opt ->
          val = value(opt)

          if current?(val, current, normalizer) do
            display(opt)
          end
        end)
      end

      def value({value, _display}), do: value
      def value(value), do: value

      def display({_value, display}), do: display
      def display(display), do: display

      def current(%{current_val: curr, normalizer: normalizer}) when not is_nil(curr),
        do: normalizer.(curr)

      def current(%{selected_params: params, param: param, normalizer: normalizer})
          when not is_nil(params),
          do: do_current(params, param, normalizer)

      def current(%{url_params: params, param: param, normalizer: normalizer}),
        do: do_current(params, param, normalizer)

      def current(_, _), do: nil

      defp do_current(params, param, normalizer) do
        with curr when not is_nil(curr) <- Map.get(params, param) do
          normalizer.(curr)
        end
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
