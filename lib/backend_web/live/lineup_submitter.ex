defmodule BackendWeb.LineupSubmitterLive do
  use BackendWeb, :surface_live_view
  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Submit
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.TextArea
  alias Surface.Components.Form.NumberInput

  data(view_url, :string, default: nil)

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
          <Form for={%{}} as={:lineups} submit="submit">
              <Field name="tournament_id">
                <Label class="label" >Tournament ID/name</Label>
                <TextInput class="input has-text-black  is-small"/>
              </Field>
              <Field name="tournament_source" :if={custom_tournament_source?(@user)}>
                <Label class="label" >Tournament Source (like organization or website)</Label>
                <TextInput class="input has-text-black  is-small" value={@user.battletag}/>
              </Field>
              <Field name="csv">
                <Label class="label">CSV of lineups: name,link or name,deck1,deck2,deck...</Label>
                <TextArea class="has-text-black"/>
              </Field>
              <Field :if={false} name="gid">
                <Label class="label" >gid taken from the url with the specific sheet open (EMPTY => LEFTMOST sheet)</Label>
                <TextInput class="input has-text-black  small" />
              </Field>
              <Field :if={false} name="sheet_id">
                  <Label class="label" >Sheet it from the google sheets url</Label>
                  <TextInput class="input has-text-black  small"/>
              </Field>
              <Field :if={false} name="ignore_columns">
                  <Label class="label" >Ignore Columns (first non ignored column should be the name then the rest should be decks)</Label>
                  <NumberInput class="input has-text-black " value={"1"}/>
              </Field>
              <Submit label="Save Lineups" class="button is-success"/>
              <div :if={@view_url}>
                View lineups <a href={@view_url}>Here</a>
              </div>
          </Form>
        </div>
      </div>
    """
  end

  def allowed(%{battletag: bt}) when is_binary(bt), do: true
  def allowed(_), do: false

  def handle_event(
        "submit",
        %{"lineups" => %{"csv" => csv, "tournament_id" => tournament_id} = params},
        %{assigns: %{user: %{battletag: battletag}}} = socket
      ) do
    # this is so stupid, why do I need to give it a streeam AND have it end with new line
    data =
      csv
      |> String.split(["\n", "\r\n"])
      |> Enum.map(&(&1 <> "\n"))
      |> Command.ImportLineups.parse_csv()

    source =
      if custom_tournament_source?(socket.assigns.user) do
        Map.get(params, "tournament_source", battletag)
      else
        battletag
      end

    Command.ImportLineups.import(data, tournament_id, source)
    {:noreply, socket |> assign(:view_url, ~p"/tournament-lineups/#{source}/#{tournament_id}")}
  end

  defp custom_tournament_source?(user),
    do: Backend.UserManager.User.can_access?(user, :tournament_source)

  # def handle_event("submit", %{"new_round" => attrs_raw}, socket) do
  #   csv_url = csv_url(attrs_raw)
  #   ignore_columns = Util.to_int(attrs_raw["ignore_columns"], 1)

  #   Command.ImportLineups.import_from_csv_url(
  #     csv_url,
  #     attrs_raw["tournament_id"],
  #     attrs_raw["tournament_source"],
  #     & &1,
  #     ignore_columns
  #   )

  #   {:noreply, socket}
  # end

  def csv_url(%{"sheet_id" => sheet_id} = attrs) do
    "https://docs.google.com/spreadsheets/d/#{sheet_id}/export?format=csv"
    |> append_gid(attrs)
  end

  defp append_gid(url, %{"gid" => ""}), do: url
  defp append_gid(url, %{"gid" => gid}), do: url <> "&gid=#{gid}"
end
