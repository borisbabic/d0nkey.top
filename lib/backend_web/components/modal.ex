defmodule Components.Modal do
  use BackendWeb, :surface_live_component
  prop(button_title, :string, required: false, default: nil)
  prop(button_class, :string, required: false, default: "button")
  prop(title, :string, required: true)
  prop(show_modal, :boolean, default: false)
  prop(show_success, :boolean, default: false)
  prop(show_error, :boolean, default: false)
  prop(success_message, :string, default: "Success")
  prop(error_message, :string, default: "Error")
  prop(cancel_button_message, :string, default: "Cancel")
  prop(show_body, :boolean, default: true)

  prop(show_footer, :boolean, default: true)
  prop(show_cancel_button, :boolean, default: true)

  slot(background, required: false)
  slot(footer, required: false)
  slot(default, required: true)

  @message_reset_assigns [show_error: false, show_success: false]
  def render(assigns) do
    ~F"""
    <div>
      <button class={@button_class} type="button" :on-click="show_modal">{@button_title || @title}</button>
      <div :if={@show_success} class="notification is-success tag">{@success_message}</div>
      <div :if={@show_modal} class="modal is-active">
        <div class="modal-background"><#slot {@background} /></div>
        <div class="modal-card">
          <header class="modal-card-head">
              <p class="modal-card-title">{@title}</p>
              <button class="delete" type="button" aria-label="close" :on-click="hide_modal"></button>
          </header>
          <section :if={@show_body} class="modal-card-body">
            <#slot/>
          </section>
          <footer :if={@show_footer} class="modal-card-foot">
            <#slot {@footer} />
            <button :if={@show_cancel_button} class="button" type="button" :on-click="hide_modal">{@cancel_button_message}</button>
            <div :if={@show_error} class="notification is-warning tag">{@error_message}</div>
          </footer>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("show_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: true) |> assign(@message_reset_assigns)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: false) |> assign(@message_reset_assigns)}
  end

  @message_reset_assigns [show_error: false, show_success: false]

  def handle_result(result, _socket, modal_id) do
    additional_assigns =
      case result do
        {:ok, _} -> [show_success: true, show_error: false, show_modal: false]
        {:error, _} -> [show_error: true]
      end

    send_update(__MODULE__, [{:id, modal_id} | additional_assigns])
  end

  def reset_messages(modal_id) when is_binary(modal_id) do
    send_update(__MODULE__, [{:id, modal_id} | @message_reset_assigns])
  end
end
