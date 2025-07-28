defmodule Components.DeckSheetsModal do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.Modal
  alias Backend.Sheets
  alias Backend.Sheets.DeckSheet
  alias Backend.UserManager

  prop(user, :any, required: true)
  prop(existing, :any, default: nil)
  prop(button_title, :string, default: nil)

  def render(assigns) do
    ~F"""
    <div>
      <Modal
        id={id(@existing)}
        button_title={@button_title || button_title(@existing)}
        :if={!@existing || Sheets.can_admin?(@existing, @user)}
        title={title(@existing)}>
        <.form for={:deck_sheet} id={"sheet_form_#{id(@existing)}"} phx-submit="submit" phx-target={@myself}>
          <div class="field">
            <label class="label" for="name">Name</label>
            <input
              class="input has-text-black is-small"
              type="text"
              name="deck_sheet[name]"
              id="name"
              value={name(@existing)}
            />
          </div>
          <div class="field">
            <label class="label" for="public_role">Public Role</label>
            <select
              class="select has-text-black"
              name="deck_sheet[public_role]"
              id="public_role"
              value={public_role(@existing) || :nothing}
            >
              <option :for={{label, value} <- roles()} value={value} selected={value == (public_role(@existing) || :nothing)}>{label}</option>
            </select>
          </div>
          <div class="field">
            <label class="label" for="group_id">Group</label>
            <select
              class="select has-text-black"
              name="deck_sheet[group_id]"
              id="group_id"
              value={group_id(@existing)}
            >
              <option :for={{label, value} <- group_options(@user)} value={value} selected={value == group_id(@existing)}>{label}</option>
            </select>
          </div>
          <div class="field">
            <label class="label" for="group_role">Group Role</label>
            <select
              class="select has-text-black"
              name="deck_sheet[group_role]"
              id="group_role"
              value={group_role(@existing) || :contributor}
            >
              <option :for={{label, value} <- roles()} value={value} selected={value == (group_role(@existing) || :contributor)}>{label}</option>
            </select>
          </div>
          <div class="field">
            <label class="label" for="default_sort">Default Sort</label>
            <select
              class="select has-text-black"
              name="deck_sheet[default_sort]"
              id="default_sort"
              value={default_sort(@existing) || "asc_inserted_at"}
            >
              <option :for={{label, value} <- sort_options(@existing)} value={value} selected={value == (default_sort(@existing) || "asc_inserted_at")}>{label}</option>
            </select>
          </div>
        </.form>
        <:footer>
          <button type="submit" class="button is-success" form={"sheet_form_#{id(@existing)}"}>Save</button>
        </:footer>
      </Modal>
    </div>
    """
  end

  defp sort_options(sheet) do
    DeckSheet.listing_sort_options(sheet)
  end

  defp default_sort(%{default_sort: default_sort}), do: default_sort
  defp default_sort(_), do: nil

  defp group_options(user) do
    group_options =
      UserManager.user_groups(user)
      |> Enum.map(&{&1.name, &1.id})

    [{"None", nil} | group_options]
  end

  defp roles() do
    DeckSheet.available_roles()
    |> Enum.map(&{DeckSheet.role_display(&1), &1})
  end

  defp name(%{name: name}), do: name
  defp name(_), do: nil

  defp public_role(%{public_role: public_role}), do: public_role
  defp public_role(_), do: nil

  defp group_role(%{group_role: group_role}), do: group_role
  defp group_role(_), do: nil

  defp group_id(%{group_id: group_id}), do: group_id
  defp group_id(_), do: nil

  defp id(%{id: id}), do: "edit_deck_sheet_inner_#{id}"
  defp id(_), do: "new_deck_sheet_inner"

  defp button_title(%{id: id}) when is_integer(id), do: "Edit"
  defp button_title(_), do: "New"

  defp title(%{id: id, name: name}) when is_integer(id), do: "Edit #{name}"
  defp title(_), do: "New Deck Sheet"

  def handle_event(
        "submit",
        %{"deck_sheet" => attrs},
        socket = %{assigns: %{user: user, existing: existing}}
      ) do
    if existing do
      Sheets.edit_deck_sheet(existing, attrs, user)
    else
      {name, rest} = Map.pop(attrs, "name")
      Sheets.create_deck_sheet(user, name, rest)
    end
    |> Modal.handle_result(socket, id(existing))

    {:noreply, socket}
  end
end
