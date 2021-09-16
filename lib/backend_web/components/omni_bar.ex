defmodule Components.OmniBar do
  @moduledoc "Add omni bar to search the site and do stuff"

  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.Form.TextInput
  alias OmniBar.Result
  alias Components.OmniBarResult
  alias Components.OmniBarHelp

  prop(search, :string, default: "")
  prop(results, :list, default: [])

  def render(assigns) do
    ~H"""
      <div>
        <div class="level is-mobile">
          <div class="level-item">
            <Form for={{:search}} change="change" submit="change">
              <TextInput value={{@search}} class="input" opts={{ placeholder: "Type or paste" }}/>
            </Form>
          </div>

          <div class="level-item">
            <OmniBarHelp id="omni_bar_help" />
          </div>
        </div>
        <div :if={{ @results |> Enum.any?() }} class="dropdown is-active">
          <div class="dropdown-menu">
            <div class="dropdown-content">
              <div :for={{ result <- sorted(@results) }} class="dropdown-item">
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
    OmniBar.search(search, create_handle_result(self()))
    {:noreply, update_search(socket, search)}
  end

  def update_search(socket, search) do
    new_results = socket.assigns.results |> Enum.filter(&(&1.search_term == search))
    assigns = [results: new_results, search: search]
    assign(socket, assigns)
  end

  @spec
  def create_handle_result(pid) do
    fn results ->
      if is_list(results) do
        results
      else
        [results]
      end
      |> Enum.reduce(false, fn result, carry ->
        Process.send_after(pid, {:incoming_result, result}, 0)
        carry || false
      end)
    end
  end

  defp sorted(results), do: Enum.sort_by(results, & &1.priority, :desc)

  @spec incoming_result(Result.t(), String.t()) :: any()
  def incoming_result(result, id) do
    send_update(__MODULE__, id: id, incoming_result: result)
  end
end
