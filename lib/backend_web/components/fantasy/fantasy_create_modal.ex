defmodule Components.FantasyCreateModal do
  use Surface.LiveComponent

  prop(show_modal, :boolean, default: false)
  prop(show_success, :boolean, default: false)
  prop(show_error, :boolean, default: false)
  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.NumberInput
  alias Surface.Components.Form.HiddenInput
  alias Surface.Components.Form.Select
  alias Surface.Components.Form.Submit
  alias Surface.Components.Form.Label

  def render(assigns) do
    ~H"""
    <div>
      <button class="button" type="button" :on-click="show_modal"> Create Fantasy League</button>
      <div :if={{ @show_success }} class="notification is-success tag">League Created!</div>
      <div class="modal is-active" :if={{ @show_modal }}>
        <Form for={{ :league }} submit="submit">
          <div class="modal-background"></div>
          <div class="modal-card">
            <header class="modal-card-head">
              <p class="modal-card-title">Create Fantasy League</p>
              <button class="delete" aria-label="close" :on-click="hide_modal"></button>
            </header>
            <section class="modal-card-body">

              <Field name="name">
                <Label class="label">Name</Label>
                <TextInput class="input is-small"/>
              </Field>

              <Field name="max_teams">
                <Label class="label">Max Teams</Label>
                <NumberInput class="input is-small"/>
              </Field>

              <Field name="roster_size">
                <Label class="label">Roster Size</Label>
                <NumberInput class="input is-small"/>
              </Field>

              <Field name="competition">
                <Label class="label">Competition</Label>
                <Select class="select" options= {{"Ironforge": "Ironforge" }} />
              </Field>

              <Field name="point_system">
                <Label class="label">Point System</Label>
                <Select class="select" options= {{"GM Points": "gm_points_2021" }} />
              </Field>

              <Field name="owner_id">
                <Context get={{ user: user }}>
                  <HiddenInput value={{ user.id }}/>
                </Context>
              </Field>
              

            </section>
            <footer class="modal-card-foot">
              <Submit label="Save" class="button is-success" />
              <button class="button" :on-click="hide_modal">Cancel</button>
              <div :if={{ @show_error }} class="notification is-warning tag">Error creating league!</div>
            </footer>
          </div>
        </Form>
      </div>
    </div>
    """
  end

  def handle_event("submit", %{"league" => attrs_raw}, socket) do
    {owner_id, attrs} =
      attrs_raw
      |> Map.put("competition_type", "masters_tour")
      |> Map.pop("owner_id")

    result =
      attrs
      |> Backend.Fantasy.create_league(owner_id)
      |> case do
        {:ok, _} -> [show_success: true, show_modal: false]
        {:error, _} -> [show_error: true]
      end

    {
      :noreply,
      socket
      |> reset_messages()
      |> assign(result)
    }
  end

  def handle_event("show_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: true) |> reset_messages()}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: false) |> reset_messages()}
  end

  defp reset_messages(socket), do: socket |> assign(show_error: false, show_succes: false)
end
