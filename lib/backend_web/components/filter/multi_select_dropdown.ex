defmodule Components.MultiSelectDropdown do
  @moduledoc false
  use BackendWeb, :surface_live_component
  use Components.Filter.DropdownBase, current_is_list: true
  alias Components.Dropdown
  alias Surface.Components.LivePatch
  alias Surface.Components.Form
  alias Surface.Components.Form.TextInput

  prop(show_search, :boolean, default: true)
  prop(selected_to_top, :boolean, default: true)
  prop(matches_search, :fun, required: true)

  data(search, :string, default: "")
  prop(default_selector, :fun, required: false, default: &__MODULE__.default_selected/1)
  data(selected, :list, default: [])

  def render(assigns = %{actual_title: _}) do
    ~F"""
        <span>
          <Dropdown title={@actual_title} selected_as_title={false}>
            <Form :if={@show_search} for={%{}} as={:search} change="search" submit="search" opts={autocomplete: "off"}>
              <div class="columns is-mobile is-multiline">
                <div class="column is-narrow">
                  <TextInput class="input" opts={placeholder: "Search"}/>
                </div>
              </div>
            </Form>
            <a :if={@selected_to_top} class="dropdown-item is-active" :on-click="remove_selected" :for={selected <- @selected} phx-value-value={value(selected)}>
              {display(selected)}
            </a>
            <a :if={@selected_to_top} class="dropdown-item" :for={unselected <- unselected(@search, @options, @selected)} :on-click="add_selected" phx-value-value={value(unselected)}>
              {display(unselected)}
            </a>
            <a 
              :if={!@selected_to_top} 
              :for={opt <- unselected(@search, @options)}
              class={"dropdown-item", "is-active": selected?(value(opt), @current, @normalizer)}
              :on-click={merged_on_click(value(opt), @current, @normalizer)}
              phx-value-value={value(opt)}>
                {display(opt)}
            </a>
          </Dropdown>
        </span>
    """
  end

  def default_selected(_) do
    []
  end

  def add_to_empty(assigns) do
    assigns
    |> add_title_current()
    |> add_selected()
  end

  defoverridable add_to_empty: 1

  def add_selected(%{current: empty, default_selector: default_selector} = assigns)
      when empty in [nil, []] do
    selected = default_selector.(assigns)
    Map.put(assigns, :selected, selected)
  end

  def add_selected(%{current: current, normalizer: normalizer, options: options} = assigns) do
    normalized_current = apply_normalizer_to_current(current, normalizer)

    selected =
      Enum.filter(normalized_current, fn opt ->
        val = opt |> value() |> normalizer.()
        val in options
      end)

    Map.put(assigns, :selected, selected)
  end

  def render(assigns), do: assigns |> add_to_empty() |> render()

  def handle_event(
        "add_selected",
        %{"value" => value},
        %{
          assigns: %{
            options: options,
            normalizer: normalizer,
            selected: selected
          }
        } = socket
      ) do
    matcher = value_matcher(value, normalizer)
    opt = Enum.find(options, matcher)

    if opt do
      {:noreply, update_selected(socket, [opt | selected])}
    else
      {:noreply, socket}
    end
  end

  def handle_event(
        "remove_selected",
        %{"value" => value},
        %{assigns: %{normalizer: normalizer, selected: selected}} = socket
      ) do
    value_matcher = value_matcher(value, normalizer)
    new_selected = Enum.reject(selected, value_matcher)
    {:noreply, update_selected(socket, new_selected)}
  end

  def handle_event("search", %{"search" => [search]}, socket),
    do: {:noreply, assign(socket, :search, search)}

  def handle_event(event, other, socket) do
    IO.inspect({event, other}, label: :other_event)
    {:noreply, socket}
  end

  defp selected?(value, selected, normalizer) do
    normalized = normalizer.(value)

    Enum.any?(selected, &(normalizer.(&1) == normalized))
    |> IO.inspect(label: "#{value} - #{inspect(selected)}")
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
    push_patch(socket, to: Routes.live_path(socket, live_view, path_params, new_params))
  end

  def unselected(search, options, selected \\ []) do
    num_to_show = (7 - Enum.count(selected)) |> max(3)

    options
    |> Enum.reject(&(value(&1) == selected))
    |> Enum.filter(fn opt ->
      display(opt) =~ search
    end)
    |> Enum.take(num_to_show)
  end
end
