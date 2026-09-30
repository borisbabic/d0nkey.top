defmodule Components.Modal do
  @moduledoc false
  use BackendWeb, :surface_live_component
  prop(button_title, :string, required: false, default: nil)
  prop(button_class, :string, required: false, default: "button")
  prop(title, :string, required: true)
  data(show_modal, :boolean, default: false)
  prop(body_class, :css_class, default: "")
  prop(cancel_button_message, :string, default: "Cancel")
  prop(show_body, :boolean, default: true)

  prop(show_footer, :boolean, default: true)
  prop(show_cancel_button, :boolean, default: true)

  slot(background, required: false)
  slot(footer, required: false)
  slot(default, required: true)

  def render(assigns) do
    ~F"""
    <span>
      <button class={@button_class} type="button" :on-click="show_modal">{@button_title || @title}</button>
      <div :if={@show_modal} class="modal is-active" role="dialog" aria-modal="true" aria-label={if is_binary(@title), do: @title, else: "Open Modal"}>
        <div class="modal-background"><#slot {@background} /></div>
        <div class="modal-card !tw-max-h-[85dvh]">
          <header class="modal-card-head">
              <p class="modal-card-title">{@title}</p>
              <button class="delete" type="button" aria-label="Close modal" :on-click="hide_modal"></button>
          </header>
          <section :if={@show_body} class={"modal-card-body", @body_class}>
            <#slot/>
          </section>
          <footer :if={@show_footer} class="modal-card-foot">
            <#slot {@footer} />
            <button :if={@show_cancel_button} class="button" type="button" :on-click="hide_modal">{@cancel_button_message}</button>
          </footer>
        </div>
      </div>
    </span>
    """
  end

  def handle_event("show_modal", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  @doc """
  Shows the result of the modal action as a flash message, closing the modal on success.
  The modal stays open on error so the user can fix the input.
  """
  @spec handle_result(any(), String.t(), String.t(), String.t()) :: any()
  def handle_result({:ok, _}, modal_id, success_message, _error_message) do
    __MODULE__.hide_modal(modal_id)
    put_component_flash(:success, success_message)
  end

  def handle_result(_error, _modal_id, _success_message, error_message),
    do: put_component_flash(:error, error_message)

  def hide_modal(modal_id) do
    send_update(__MODULE__, id: modal_id, show_modal: false)
  end

  def show_modal(modal_id) do
    send_update(__MODULE__, id: modal_id, show_modal: false)
  end
end
