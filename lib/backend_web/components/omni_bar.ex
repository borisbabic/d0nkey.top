defmodule Components.OmniBar do
  @moduledoc "Add omni bar to search the site and do stuff"

  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.Form.TextInput
  alias OmniBar.Result
  alias Components.OmniBarResult

  prop(search, :string, default: "")
  prop(results, :list, default: [])

  def render(assigns) do
    IO.inspect(assigns.results, label: "assigned results")

    ~H"""
      <div>
        <Form for={{:search}} change="change" submit="change">
          <TextInput value={{@search}} class="input" opts={{ placeholder: "Omni bar" }}/>
        </Form>
        <div :if={{ @results |> Enum.any?() }} class="dropdown is-active">
          <div class="dropdown-menu">
            <div class="dropdown-content">
              <div :for={{ result <- sorted(@results) }}>
                <OmniBarResult result={{ result }} />
              </div>
            </div>
          </div>
        </div>
      </div>

    """
  end

  def update(
        assigns = %{incoming_result: result},
        socket = %{assigns: %{results: results, search: search}}
      ) do
    new_results =
      if result.search_term == search do
        [result | results]
      else
        results
      end
      |> Enum.uniq_by(& &1.result_id)

    assigns
    |> Map.delete(:incoming_result)
    |> Map.put(:results, new_results)
    |> update(socket)
  end

  def update(assigns = %{search: search}, socket = %{assigns: %{results: results}}) do
    new_results = results |> Enum.filter(search)
    {:ok, socket |> assign(assigns) |> assign(results: new_results)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("change", %{"search" => [search]}, socket) do
    OmniBar.search(search, &handle_result/1)
    {:noreply, update_search(socket, search)}
  end

  def update_search(socket, search) do
    new_results = socket.assigns.results |> Enum.filter(&(&1.search_term == search))
    assigns = [results: new_results, search: search]
    assign(socket, assigns)
  end

  @spec handle_result([Result.t()] | Result.t()) :: boolean
  def handle_result(results) when is_list(results),
    do: Enum.reduce(results, false, &(&2 && handle_result(&1)))

  def handle_result(result) do
    Process.send_after(self(), {:incoming_result, result}, 0)
    false
  end

  defp sorted(results), do: Enum.sort_by(results, & &1.priority, :desc)

  def incoming_result(result, id) do
    send_update(__MODULE__, id: id, incoming_result: result)
  end
end
