defmodule Components.DeleteModal do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.Modal

  prop(button_title, :string, default: "Delete")
  prop(on_delete, :fun, required: true)
  prop(title, :string, default: "Are you sure?")
  prop(delete_button_text, :string, default: "Delete")
  prop(success_message, :string, default: "Deleted")
  prop(error_message, :string, default: "Could not delete")
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
          <span>
          </span>
          <:footer>
            <button :on-click="delete" class="button">{@delete_button_text}</button>
          </:footer>
        </Modal>
      </div>
    """
  end

  def handle_event("delete", _, %{assigns: assigns} = socket) do
    %{on_delete: on_delete, modal_id: modal_id} = assigns
    result = on_delete.() |> normalize_result()

    Modal.handle_result(result, modal_id, assigns.success_message, assigns.error_message)

    {:noreply, socket}
  end

  defp normalize_result({success, _} = result) when success in [:ok, :error], do: result
  defp normalize_result(result), do: {:ok, result}
end
