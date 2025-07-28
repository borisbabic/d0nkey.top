defmodule Components.MultiSelectDropdown do
  @moduledoc false
  use BackendWeb, :surface_live_component
  use Components.Filter.DropdownBase, current_is_list: true
  alias FunctionComponents.Dropdown

  prop(show_search, :boolean, default: true)
  prop(selected_to_top, :boolean, default: true)
  prop(matches_search, :fun, required: true)
  prop(class, :css_class, default: nil)

  prop(search_event, :event, default: %{name: "search"})
  data(search, :string, default: "")
  prop(default_selector, :fun, required: false, default: &__MODULE__.default_selected/1)
  prop(updater, :fun, required: false, default: &__MODULE__.update_selected/2)
  prop(num_to_show, :number, required: false, default: 7)
  prop(any_as_empty, :boolean, default: true)
  data(selected, :list, default: [])

  def render(%{actual_title: _} = assigns) do
    ~F"""
        <span class={@class}>
          <Dropdown.menu title={@actual_title} aria-multiselectable="true">
            <.form :if={@show_search} phx-target={target(@search_event, @myself)} phx-change={name(@search_event)} phx-submit={name(@search_event)} >
              <input name="search" type="text" class="input has-text-black" placeholder="Search" autocomplete="off" />
            </.form>
            <Dropdown.item :for={selected <- @selected} selected={true} :if={@selected_to_top} phx-target={@myself} phx-click="remove_selected" phx-value-value={value(selected)}>
              {display(selected)}
            </Dropdown.item>
            <Dropdown.item selected={false} :for={unselected <- unselected(@search, @options, @num_to_show, @selected, @normalizer)} :if={@selected_to_top} phx-target={@myself} phx-click="add_selected" phx-value-value={value(unselected)}>
              {display(unselected)}
            </Dropdown.item>
            <Dropdown.item
              :if={!@selected_to_top}
              :for={opt <- unselected(@search, @options, @num_to_show)}
              selected={selected?(value(opt), @current, @normalizer)}
              phx-target={@myself}
              aria-selected={selected?(value(opt), @current, @normalizer)}
              phx-click={merged_on_click(value(opt), @current, @normalizer)}
              phx-value-value={value(opt)}>
                  {display(opt)}
            </Dropdown.item>
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

  def handle_event(_event, _other, socket) do
    {:noreply, socket}
  end

  defp selected?(value, selected, normalizer) do
    normalized = normalizer.(value)

    Enum.any?(selected, &(normalizer.(&1) == normalized))
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

  defp unselected(search, options, base_num_to_show, selected \\ [], normalizer \\ & &1) do
    num_to_show = (base_num_to_show - Enum.count(selected)) |> max(3)
    normalized_search = normalize_search(search)

    normalized_selected =
      Enum.map(selected, fn s ->
        s
        |> value()
        |> normalizer.()
      end)

    options
    |> Enum.reject(&(normalizer.(value(&1)) in normalized_selected))
    |> Enum.filter(fn opt ->
      normalize_search(opt && display(opt) && display(opt)) =~ normalized_search
    end)
    |> Enum.take(num_to_show)
  end

  defp normalize_search(search) do
    search
    |> to_string()
    |> String.downcase()
  end
end
