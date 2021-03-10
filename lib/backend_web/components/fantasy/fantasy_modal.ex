defmodule Components.FantasyModal do
  use Surface.LiveComponent

  prop(show_modal, :boolean, default: false)
  prop(show_success, :boolean, default: false)
  prop(show_error, :boolean, default: false)
  prop(league, :map, default: %Backend.Fantasy.League{})
  prop(title, :string, default: "Fantasy League")
  prop(success_message, :string, default: "Fantasy League Saved!")
  prop(error_message, :string, default: "Error Saving League!")
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
        <Form for={{ :league }} submit="submit">
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
                <Select selected={{ @league.competition }} class="select" options= {{"Ironforge": "Ironforge"}} />
              </Field>

              <Field name="competition_type">
                <HiddenInput value={{ @league.competition_type || "masters_tour" }}/>
              </Field>

              <Field name="point_system">
                <Label class="label">Point System</Label>
                <Select selected={{ @league.point_system }} class="select" options={{"GM Points": "gm_points_2021", "Swiss Wins": "swiss_wins" }} />
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

  def handle_event(
        "submit",
        %{"league" => attrs},
        socket = %{assigns: %{league: league = %{id: id}}}
      )
      when not is_nil(id) do
    league
    |> Backend.Fantasy.update_league(attrs)
    |> handle_result(socket)
  end

  def handle_event("submit", %{"league" => attrs_raw}, socket) do
    {owner_id, attrs} =
      attrs_raw
      |> Map.pop("owner_id")

    attrs
    |> Backend.Fantasy.create_league(owner_id)
    |> handle_result(socket)
  end

  def handle_event("regenerate_join_code", _, socket = %{assigns: %{league: league}}) do
    new_league = league |> Map.put(:join_code, Ecto.UUID.generate())

    {
      :noreply,
      socket |> assign(:league, new_league)
    }
  end

  def handle_event("show_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: true) |> reset_messages()}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, socket |> assign(show_modal: false) |> reset_messages()}
  end

  def reset_messages(socket), do: socket |> assign(show_error: false, show_succes: false)

  defp handle_result(result, socket) do
    assigns =
      case result do
        {:ok, _} -> [show_success: true, show_modal: false]
        {:error, _} -> [show_error: true]
      end

    {
      :noreply,
      socket
      |> reset_messages()
      |> assign(assigns)
    }
  end
end
