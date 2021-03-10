defmodule Components.DraftModal do
  use Surface.LiveComponent

  prop(league, :map, default: %Backend.Fantasy.League{})
  prop(draft, :map, default: %Backend.Fantasy.Draft{})

  prop(show_modal, :boolean, default: false)
  prop(show_success, :boolean, default: false)
  prop(show_error, :boolean, default: false)

  prop(title, :string, default: "Fantasy Draft")
  prop(success_message, :string, default: "Fantasy Draft Saved!")
  prop(error_message, :string, default: "Error Saving Draft!")

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
      <button class="button" type="button" :on-click="show_modal">{{ @title }}</button>
      <div :if={{ @show_success }} class="notification is-success tag">{{ @success_message }}</div>
      <div class="modal is-active" :if={{ @show_modal }}>
        <Form for={{ :draft }} submit="submit">
          <div class="modal-background"></div>
          <div class="modal-card">
            <header class="modal-card-head">
              <p class="modal-card-title">{{ @title }}</p>
              <button class="delete" type="button" aria-label="close" :on-click="hide_modal"></button>
            </header>
            <section class="modal-card-body">

              <Field name="name">
                <Label class="label">Name</Label>
                <TextInput class="input is-small" value={{ @league.name }}/>
              </Field>

              <Field name="max_teams">
                <Label class="label">Max Teams</Label>
                <NumberInput class="input is-small" value={{ @league.max_teams }}/>
              </Field>

              <Field name="roster_size">
                <Label class="label">Roster Size</Label>
                <NumberInput class="input is-small" value= {{ @league.roster_size }}/>
              </Field>

              <Field name="competition">
                <Label class="label">Competition</Label>
                <Select class="select" options= {{"Ironforge": "Ironforge" }} />
              </Field>

              <Field name="competition_type">
                <HiddenInput value={{ @league.competition_type || "masters_tour" }}/>
              </Field>

              <Field name="point_system">
                <Label class="label">Point System</Label>
                <Select class="select" options={{"GM Points": "gm_points_2021" }} />
              </Field>

              <Field :if={{ @league.join_code }} name="join_code">
                <Label class="label">Join Code</Label>
                {{ @league.join_code }}
                <button class="button" type="button" :on-click="regenerate_join_code">Regenerate</button>
              </Field>

              <Field name="owner_id">
                <Context get={{ user: user }}>
                  <HiddenInput value={{ user.id }}/>
                </Context>
              </Field>
              

            </section>
            <footer class="modal-card-foot">
              <Submit label="Save" class="button is-success" />
              <button class="button" type="button" :on-click="hide_modal">Cancel</button>
              <div :if={{ @show_error }} class="notification is-warning tag">{{ @error_message }}</div>
            </footer>
          </div>
        </Form>
      </div>
    </div>
    """
  end
end
