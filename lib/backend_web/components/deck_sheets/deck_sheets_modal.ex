defmodule Components.DeckSheetsModal do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Components.Modal
  alias Backend.Sheets
  alias Backend.Sheets.DeckSheet
  alias Backend.UserManager
  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.Submit
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Select

  prop(user, :any, required: true)
  prop(existing, :any, default: nil)
  prop(button_title, :string, default: nil)

  def render(assigns) do
    ~F"""
    <div>
      <Modal
        id={id(@existing)}
        button_title={@button_title || button_title(@existing)}
        :if={Sheets.can_admin?(@existing, @user)}
        title={title(@existing)}>
        <Form for={%{}} as={:deck_sheet} submit="submit" opts={id: "sheet_form_#{id(@existing)}"}>
          <Field name={:name}>
            <Label class="label">Name</Label>
            <TextInput class="input is-small" value={name(@existing)}/>
          </Field>
          <Field name={:public_role}>
            <Label class="label">Public Role</Label>
            <Select class="select" selected={public_role(@existing) || :nothing} options={roles()}/>
          </Field>
          <Field  name={:group_id}>
            <Label class="label">Group</Label>
            <Select class="select" selected={group_id(@existing)}  options={group_options(@user)} />
          </Field>
          <Field name={:group_role}>
            <Label class="label">Group Role</Label>
            <Select class="select" selected={group_role(@existing) || :contributor} options={roles()}/>
          </Field>
        </Form>
        <:footer>
          <Submit label="Save" class="button is-success" opts={form: "sheet_form_#{id(@existing)}"}/>
        </:footer>
      </Modal>
    </div>
    """
  end

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
