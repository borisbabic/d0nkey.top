defmodule Components.MultiSelectDropdown do
  @moduledoc false
  use BackendWeb, :surface_live_component
  use Components.Filter.DropdownBase, current_is_list: true
  alias FunctionComponents.Dropdown

  prop(show_search, :boolean, default: true)
  prop(selected_to_top, :boolean, default: true)
  prop(matches_search, :fun, required: true)
  prop(class, :css_class, default: nil)

  prop(select_all, :boolean, default: false)
  prop(scrollable, :boolean, default: false)
  prop(clear, :boolean, default: true)

  prop(search_event, :event, default: %{name: "search"})
  data(search, :string, default: "")
  prop(default_selector, :fun, required: false, default: &__MODULE__.default_selected/1)
  prop(updater, :fun, required: false, default: &__MODULE__.update_selected/2)
  prop(num_to_show, :number, required: false, default: 7)
  prop(any_as_empty, :boolean, default: true)
  prop(warning, :boolean, default: false)
  data(selected, :list, default: [])

  def render(%{actual_title: _} = assigns) do
    ~F"""
        <span id={@id} class={@class}>
          <Dropdown.menu title={@actual_title} aria-multiselectable="true" warning?={@warning} >
            <.form :if={@show_search} id={"#{@id}_search_form"} phx-change={name(@search_event)} phx-submit={name(@search_event)} phx-target={target(@search_event, @myself)} >
              <input name="search" type="text" class="input has-text-black" placeholder="Search" aria-label={"Search #{@actual_title || "options"}"} autocomplete="off" />
            </.form>
            <button
              :if={@select_all}
              type="button"
              id={@id <> "_select_all_btn"}
              class="tw-w-full tw-text-left tw-px-3 tw-py-1.5 tw-text-xs tw-font-medium tw-text-sky-400 hover:tw-bg-slate-700/50 tw-rounded-md tw-mb-1"
              phx-click="select_all"
              phx-target={@myself}
            >
              Select All
            </button>
            <button
              :if={show_clear?(@clear, @selected, @current)}
              type="button"
              id={@id <> "_clear_btn"}
              class="tw-w-full tw-text-left tw-px-3 tw-py-1.5 tw-text-xs tw-font-medium tw-text-sky-400 hover:tw-bg-slate-700/50 tw-rounded-md tw-mb-1"
              phx-click="clear"
              phx-target={@myself}
            >
              Clear
            </button>
            <div class={[@scrollable && "tw-max-h-60 tw-overflow-y-auto"]}>
              <Dropdown.item :for={selected <- @selected} selected={true} :if={@selected_to_top}>
                <div class="tw-flex tw-items-center tw-justify-between tw-w-full">
                  <span
                    class="tw-flex-1 tw-cursor-pointer"
                    phx-target={@myself}
                    phx-click="remove_selected"
                    phx-value-value={value(selected)}
                  >
                    {display(selected)}
                  </span>
                </div>
              </Dropdown.item>
              <Dropdown.item selected={false} :for={unselected <- unselected(@search, @options, @num_to_show, @selected, @normalizer, @scrollable)} :if={@selected_to_top}>
                <div class="tw-flex tw-items-center tw-justify-between tw-w-full">
                  <span
                    class="tw-flex-1 tw-cursor-pointer"
                    phx-target={@myself}
                    phx-click="add_selected"
                    phx-value-value={value(unselected)}
                  >
                    {display(unselected)}
                  </span>
                </div>
              </Dropdown.item>
              <Dropdown.item
                :if={!@selected_to_top}
                :for={opt <- unselected(@search, @options, @num_to_show, [], @normalizer, @scrollable)}
                selected={selected?(value(opt), @current, @normalizer)}
                aria-selected={selected?(value(opt), @current, @normalizer)}>
                <div class="tw-flex tw-items-center tw-justify-between tw-w-full">
                  <span
                    class="tw-flex-1 tw-cursor-pointer"
                    phx-target={@myself}
                    phx-click={merged_on_click(value(opt), @current, @normalizer)}
                    phx-value-value={value(opt)}
                  >
                    {display(opt)}
                  </span>
                </div>
              </Dropdown.item>
            </div>
          </Dropdown.menu>
        </span>
    """
  end

  def render(assigns), do: assigns |> add_to_empty() |> render()

  defp target(%{target: target}, _), do: target
  defp target(_, fallback), do: fallback

  defp name(%{name: name}) when is_binary(name), do: name
  defp name(name) when is_binary(name), do: name
  defp name(_), do: nil

  def default_selected(_) do
    []
  end

  def add_to_empty(assigns) do
    assigns
    |> Map.put_new(:clear, true)
    |> add_title_current()
    |> fix_current()
    |> add_selected()
  end

  # handle both lists and single values, including any as empty
  # why tf do I have selected and current?

  def fix_current(%{current: empty, selected: selected} = assigns)
      when empty in [nil, []] and selected not in [nil, []] do
    Map.put(assigns, :current, selected)
  end

  def fix_current(%{current: "any", any_as_empty: true} = assigns),
    do: Map.put(assigns, :current, [])

  def fix_current(%{current: current} = assigns) do
    if Enumerable.impl_for(current) do
      assigns
    else
      Map.put(assigns, :current, [current])
    end
  end

  def fix_current(assigns), do: assigns

  defoverridable add_to_empty: 1

  defp add_selected(%{current: empty, default_selector: default_selector} = assigns)
       when empty in [nil, []] do
    selected = default_selector.(assigns)
    Map.put(assigns, :selected, selected || [])
  end

  defp add_selected(%{current: current, normalizer: normalizer, options: options} = assigns) do
    normalized_current = apply_normalizer_to_current(current, normalizer)

    selected =
      Enum.filter(options, fn opt ->
        val = opt |> value() |> normalizer.()
        val in normalized_current
      end)

    Map.put(assigns, :selected, selected || [])
  end

  def update(assigns, socket) do
    new_assigns = assigns |> add_to_empty()
    {:ok, assign(socket, new_assigns)}
  end

  def handle_event(
        "add_selected",
        %{"value" => value},
        %{
          assigns: %{
            options: options,
            updater: updater,
            normalizer: normalizer,
            current: current
          }
        } = socket
      ) do
    matcher = value_matcher(value, normalizer)
    opt = Enum.find(options, matcher)

    if opt do
      {:noreply, updater.(socket, [value(opt) | current])}
    else
      {:noreply, socket}
    end
  end

  def handle_event(
        "reset_selected",
        _,
        %{assigns: %{updater: updater}} = socket
      ) do
    {:noreply, updater.(socket, [])}
  end

  def handle_event(
        "clear",
        _,
        %{assigns: %{updater: updater}} = socket
      ) do
    {:noreply, updater.(socket, [])}
  end

  def handle_event(
        "remove_selected",
        %{"value" => value},
        %{assigns: %{normalizer: normalizer, current: current, updater: updater}} = socket
      ) do
    value_matcher = value_matcher(value, normalizer)
    new_selected = Enum.reject(current, value_matcher)
    {:noreply, updater.(socket, new_selected)}
  end

  def handle_event("search", %{"search" => search}, socket) when is_binary(search),
    do: {:noreply, assign(socket, :search, search)}

  def handle_event("search", %{"search" => [search]}, socket) when is_binary(search),
    do: {:noreply, assign(socket, :search, search)}

  def handle_event(
        "select_all",
        _,
        %{
          assigns: %{
            options: options,
            updater: updater,
            normalizer: normalizer,
            current: current,
            search: search,
            any_as_empty: any_as_empty
          }
        } = socket
      ) do
    search_term = normalize_search(search)

    matching_options =
      options
      |> Enum.reject(fn opt ->
        val = value(opt)
        is_nil(val) or (any_as_empty and val == "any")
      end)
      |> Enum.filter(fn opt ->
        normalize_search(opt && display(opt)) =~ search_term
      end)

    matching_values = Enum.map(matching_options, &value/1)

    new_selected =
      (current || [])
      |> Kernel.++(matching_values)
      |> Enum.uniq_by(normalizer)

    {:noreply, updater.(socket, new_selected)}
  end

  def handle_event(_event, _other, socket) do
    {:noreply, socket}
  end

  defp selected?(value, selected, normalizer) do
    normalized = normalizer.(value)

    Enum.any?(selected, &(normalizer.(&1) == normalized))
  end

  defp merged_on_click(nil, _, _) do
    "reset_selected"
  end

  defp merged_on_click(value, selected, normalizer) do
    if selected?(value, selected, normalizer) do
      "remove_selected"
    else
      "add_selected"
    end
  end

  defp value_matcher(value, normalizer) do
    normalized = normalizer.(value)

    fn opt ->
      normalized == opt or normalized == opt |> value() |> normalizer.()
    end
  end

  def update_selected(
        %{
          assigns: %{
            param: param,
            live_view: live_view,
            path_params: path_params,
            url_params: url_params
          }
        } = socket,
        new_selected
      ) do
    selected_values = Enum.map(new_selected, &value/1)
    new_params = Map.put(url_params, param, selected_values)

    if path_params do
      push_patch(socket, to: Routes.live_path(socket, live_view, path_params, new_params))
    else
      push_patch(socket, to: Routes.live_path(socket, live_view, new_params))
    end
  end

  defp unselected(
         search,
         options,
         base_num_to_show,
         selected \\ [],
         normalizer \\ &Util.id/1,
         scrollable \\ false
       ) do
    normalized_search = normalize_search(search)

    normalized_selected =
      Enum.map(selected, fn s ->
        s
        |> value()
        |> normalizer.()
      end)

    filtered =
      options
      |> Enum.reject(&(normalizer.(value(&1)) in normalized_selected))
      |> Enum.filter(fn opt ->
        normalize_search(opt && display(opt)) =~ normalized_search
      end)

    if scrollable do
      filtered
    else
      num_to_show = (base_num_to_show - Enum.count(selected)) |> max(3)
      Enum.take(filtered, num_to_show)
    end
  end

  defp normalize_search(search) do
    search
    |> to_string()
    |> String.downcase()
  end

  def multiple_selected?(selected, current) do
    valid_count =
      cond do
        is_list(selected) and not Enum.empty?(selected) ->
          selected
          |> Enum.reject(fn item ->
            val = value(item)
            is_nil(val) or val == "any" or val == ""
          end)
          |> length()

        is_list(current) ->
          current
          |> Enum.reject(fn item ->
            is_nil(item) or item == "any" or item == ""
          end)
          |> length()

        true ->
          0
      end

    valid_count > 1
  end

  defp show_clear?(clear, selected, current) do
    clear and multiple_selected?(selected, current)
  end
end
