defmodule Components.DeleteModal do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.Modal

  prop(button_title, :string, default: "Delete")
  prop(on_delete, :fun, required: true)
  prop(title, :string, default: "Are you sure?")
  prop(delete_button_text, :string, default: "Delete")
  data(modal_id, :string)

  def mount(socket) do
    {:ok, assign(socket, modal_id: "delete_modal_#{Ecto.UUID.generate()}")}
  end

  def render(assigns) do
    ~F"""
      <div>
        <Modal
          id={@modal_id}
          button_title={@button_title}
          title={@title}
          show_body={false}>

          <:footer>
            <button :on-click="delete" class="button">{@delete_button_text}</button>
          </:footer>
        </Modal>
      </div>
    """
  end

  def handle_event("delete", _, socket = %{assigns: %{on_delete: on_delete, modal_id: modal_id}}) do
    on_delete.()
    |> handle_result(socket, modal_id)

    {:noreply, socket}
  end

  defp handle_result(result = {success, _}, socket, modal_id) when success in [:ok, :error],
    do: Modal.handle_result(result, socket, modal_id)

  defp handle_result(result, socket, modal_id), do: handle_result({:ok, result}, socket, modal_id)
end
