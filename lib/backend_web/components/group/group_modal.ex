defmodule Components.GroupModal do
  @moduledoc false
  use BackendWeb, :surface_live_component

  require Logger

  prop(group, :map, default: %Backend.UserManager.Group{})
  prop(show_modal, :boolean, default: false)
  prop(show_success, :boolean, default: false)
  prop(show_error, :boolean, default: false)
  prop(success_message, :string, default: "Success")
  prop(error_message, :string, default: "Error")
  prop(cancel_button_message, :string, default: "Cancel")
  prop(current_params, :map, default: %{})
  prop(user, :map, from_context: :user)

  @message_reset_assigns [show_error: false, show_success: false]
  def render(assigns) do
    ~F"""
    <div>
      <div>
        <button class="button" type="button" :on-click="show_modal">{button_title(@group)}</button>
        <div :if={@show_success} class="notification is-success tag">{@success_message}</div>
        <div :if={@show_modal} class="modal is-active">
          <div class="modal-background"></div>
          <div class="modal-card">
            <.form for={%{}} as={:group} id="group_form" phx-change="change" phx-submit="submit">
              <header class="modal-card-head">
                <p class="modal-card-title">{title(@group)}</p>
                <button class="delete" type="button" aria-label="close" :on-click="hide_modal"></button>
              </header>
              <section class="modal-card-body">
                <div class="field">
                  <label class="label" for="name">Name</label>
                  <input
                    class="input has-text-black is-small"
                    type="text"
                    name="group[name]"
                    id="name"
                    value={@current_params["name"]}
                  />
                </div>
                <div class="field">
                  <label class="label" for="discord">Discord link (optional)</label>
                  <input
                    class="input has-text-black is-small"
                    type="text"
                    name="group[discord]"
                    id="discord"
                    value={@current_params["discord"] || @group.discord}
                  />
                </div>
                <div :if={@group.join_code} class="field">
                  <label class="label" for="join_code">Join Code</label>
                  <span>{@group.join_code}</span>
                  <button class="button" type="button" :on-click="regenerate_join_code">Regenerate</button>
                  <input type="hidden" name="group[join_code]" value={@group.join_code} />
                </div>
                <input type="hidden" name="group[owner_id]" value={@user.id} />
              </section>
              <footer class="modal-card-foot">
                <button type="submit" class="button is-success">Save</button>
                <button class="button" type="button" :on-click="hide_modal">{@cancel_button_message}</button>
                <div :if={@show_error} class="notification is-warning tag">{@error_message}</div>
              </footer>
            </.form>
          </div>
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

  def handle_event(
        "submit",
        %{"group" => attrs},
        socket = %{assigns: %{group: group = %{id: id}}}
      )
      when not is_nil(id) do
    group
    |> Backend.UserManager.update_group(attrs)
    |> handle_result(socket)
  end

  def handle_event("submit", %{"group" => attrs_raw}, socket) do
    {owner_id, attrs} =
      attrs_raw
      |> Map.pop("owner_id")

    attrs
    |> Backend.UserManager.create_group(owner_id)
    |> handle_result(socket)
  end

  def handle_event("change", params, socket) do
    {:noreply, socket |> assign_temp_vals(params)}
  end

  def handle_event("regenerate_join_code", _, socket = %{assigns: %{group: group}}) do
    new_group = group |> Map.put(:join_code, Ecto.UUID.generate())

    {
      :noreply,
      socket |> assign(:group, new_group)
    }
  end

  defp assign_temp_vals(socket, %{"group" => params}) do
    socket
    |> assign(current_params: params)
  end

  def button_title(%{id: id}) when not is_nil(id), do: "Edit Group"
  def button_title(_), do: "Create Group"
  def title(%{name: name}) when not is_nil(name), do: name
  def title(_), do: "Create Group"

  defp handle_result(result, socket) do
    assigns =
      case result do
        {:ok, _} ->
          [show_success: true, show_modal: false]

        {:error, error} ->
          Logger.warning("Error saving group #{error |> inspect()}")
      end

    {
      :noreply,
      socket
      |> assign(@message_reset_assigns)
      |> assign(assigns)
    }
  end
end
