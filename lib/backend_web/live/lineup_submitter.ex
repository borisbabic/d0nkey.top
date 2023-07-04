defmodule BackendWeb.LineupSubmitterLive do
  use BackendWeb, :surface_live_view
  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.HiddenInput
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Submit
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.NumberInput

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <div>
        <div :if={allowed(@user)}>
          <Form for={:new_round} submit="submit">
              <Field name="tournament_source">
                <HiddenInput value={"hcm_2022"}/>
              </Field>
              <Field name="tournament_id">
                <Label class="label" >Match/Round Name</Label>
                <TextInput class="input is-small"/>
              </Field>
              <Field name="gid">
                <Label class="label" >gid taken from the url with the specific sheet open (EMPTY => LEFTMOST sheet)</Label>
                <TextInput class="input small" />
              </Field>
              <Field name="sheet_id">
                  <Label class="label" >Sheet it from the google sheets url</Label>
                  <TextInput class="input small"/>
              </Field>
              <Field name="ignore_columns">
                  <Label class="label" >Ignore Columns (first non ignored column should be the name then the rest should be decks)</Label>
                  <NumberInput class="input" value={"1"}/>
              </Field>
              <Submit label="Save Lineups" class="button is-success"/>
          </Form>
        </div>
      </div>
    """
  end

  def allowed(%{battletag: bt}) when bt in ["NiceJwishOwl#1993", "D0nkey#2470"], do: true
  def allowed(_), do: false

  def handle_event("submit", %{"new_round" => attrs_raw}, socket) do
    csv_url = csv_url(attrs_raw)
    ignore_columns = Util.to_int(attrs_raw["ignore_columns"], 1)

    Command.ImportLineups.import_from_csv_url(
      csv_url,
      attrs_raw["tournament_id"],
      attrs_raw["tournament_source"],
      & &1,
      ignore_columns
    )

    {:noreply, socket}
  end

  def csv_url(attrs = %{"sheet_id" => sheet_id}) do
    "https://docs.google.com/spreadsheets/d/#{sheet_id}/export?format=csv"
    |> append_gid(attrs)
  end

  defp append_gid(url, %{"gid" => ""}), do: url
  defp append_gid(url, %{"gid" => gid}), do: url <> "&gid=#{gid}"
end
