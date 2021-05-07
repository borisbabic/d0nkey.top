defmodule Components.FantasyModal do
  @moduledoc false
  use Surface.LiveComponent

  require Logger
  prop(show_modal, :boolean, default: false)
  prop(show_success, :boolean, default: false)
  prop(show_error, :boolean, default: false)
  prop(league, :map, default: %Backend.Fantasy.League{})
  prop(title, :string, default: "Fantasy League")
  prop(success_message, :string, default: "Fantasy League Saved!")
  prop(error_message, :string, default: "Error Saving League!")
  prop(show_deadline, :boolean, default: false)
  prop(current_params, :map, default: %{})

  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.NumberInput
  alias Surface.Components.Form.HiddenInput
  alias Surface.Components.Form.Select
  alias Surface.Components.Form.Submit
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Checkbox
  alias Surface.Components.Form.DateTimeLocalInput

  import BackendWeb.FantasyHelper

  alias Backend.Fantasy
  alias Backend.MastersTour.TourStop

  def render(assigns) do
    competition_type = selected_competition_type(assigns.current_params, assigns.league)

    ~H"""
    <div>
      <button class="button" type="button" :on-click="show_modal">{{ @title }}</button>
      <div :if={{ @show_success }} class="notification is-success tag">{{ @success_message }}</div>
      <div class="modal is-active" :if={{ @show_modal }} >
        <Form for={{ :league }} change="change" submit="submit">
          <div class="modal-background"></div>
          <div class="modal-card">
            <header class="modal-card-head">
              <p class="modal-card-title">{{ @title }}</p>
              <button class="delete" type="button" aria-label="close" :on-click="hide_modal"></button>
            </header>
            <section class="modal-card-body">

              <Field name="name">
                <Label class="label">Name</Label>
                <TextInput class="input is-small" value={{ @current_params["name"] || @league.name }}/>
              </Field>

              <Field name="max_teams">
                <Label class="label">Max Teams</Label>
                <NumberInput class="input is-small" value={{ @current_params["max_teams"] || @league.max_teams }}/>
              </Field>

              <Field name="roster_size">
                <Label class="label">Roster Size</Label>
                <NumberInput class="input is-small" value= {{ @current_params["roster_size"] || @league.roster_size }}/>
              </Field>

              <Field name="competition_type">
                <Label class="label">Competition Type</Label>
                <Select selected={{ competition_type }} class="select" options={{ competition_type_options() }}/>
              </Field>

              <Field name="competition" :if={{ competition_type != "battlefy" }}>
                <Label class="label">Competition</Label>
                <Select selected={{ @current_params["competition"] || @league.competition }} class="select" options={{ competition_type |> competition_options() }} />
              </Field>

              <Field name="competition" :if={{ competition_type == "battlefy" }}>
                <Label class="label">Battlefy tournament id</Label>
                <TextInput class="input is-small" value={{ (@current_params["competition"] || @league.competition) |> battlefy_tournament_id()}} />
              </Field>


              <Field name="changes_between_rounds" :if={{ competition_type == "grandmasters" }}>
                <Label class="label">Changes Between Rounds</Label>
                <NumberInput class="input is-small" value= {{ @current_params["changes_between_rounds"] || @league.changes_between_rounds }}/>
              </Field>

              <Field name="real_time_draft">
                <Label class="label">Real Time Draft</Label>
                <Checkbox value={{ @current_params["real_time_draft"] || @league.real_time_draft }} />
              </Field>

              <Field :if={{ @league.draft_deadline || !@league.real_time_draft || @show_deadline }} name="deadline" >
                <Label class="label">Draft Deadline (UTC!)</Label>
                <DateTimeLocalInput value={{ @current_params["deadline"] || draft_deadline_value(@league, competition_type) }} />
              </Field>

              <Field name="point_system">
                <Label class="label">Point System</Label>
                <Select selected={{ @current_params["point_system"] || @league.point_system }} class="select" options={{ competition_type |> point_system_options()}} />
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

  defp battlefy_tournament_id(id) when is_binary(id) do
    id
    |> String.split("/")
    |> Enum.map(&String.trim/1)
    |> Enum.find(&Backend.Battlefy.battlefy_id?/1)
  end

  defp battlefy_tournament_id(_), do: nil

  defp current_tour_stop(), do: TourStop.get_current(96, 0)
  defp current_tour_stop?(), do: nil != current_tour_stop()

  defp competition_type_options() do
    if current_tour_stop?() do
      [{"Masters Tour", "masters_tour"}]
    else
      []
    end
    |> Kernel.++([
      {"Grandmasters", "grandmasters"},
      {"Battlefy", "battlefy"},
      {"Card Changes", "card_changes"}
    ])
  end

  defp selected_competition_type(%{"competition_type" => type}, _) when is_binary(type), do: type
  defp selected_competition_type(_, %{competition_type: type}) when is_binary(type), do: type

  defp selected_competition_type(_, _) do
    if current_tour_stop?() do
      "masters_tour"
    else
      "grandmasters"
    end
  end

  defp competition_options("grandmasters"), do: ["gm_2021_1"] |> competition_options()
  defp competition_options("card_changes"), do: ["buffs_may_2021"] |> competition_options()

  defp competition_options("masters_tour") do
    current_tour_stop()
    |> case do
      nil -> []
      id -> [id] |> competition_options()
    end
  end

  defp competition_options(competitions) when is_list(competitions),
    do: competitions |> Enum.map(&{&1 |> competition_name(), &1})

  defp competition_options(_), do: []

  defp point_system_options("grandmasters"), do: ["total_wins"] |> point_system_options()

  defp point_system_options("masters_tour"),
    do: ["swiss_wins", "gm_points_2021"] |> point_system_options()

  defp point_system_options("battlefy"),
    do: ["swiss_wins"] |> point_system_options()

  defp point_system_options("card_changes"),
    do: ["num_correct"] |> point_system_options()

  defp point_system_options(point_systems) when is_list(point_systems),
    do: point_systems |> Enum.map(&{&1 |> Fantasy.League.scoring_display(), &1})

  defp point_system_options(_), do: []

  defp gm_2021_1_start(), do: ~N[2021-04-08 09:00:00] |> Fantasy.new_league_deadline(:week)

  defp draft_deadline_value(%{draft_deadline: dd}, _) when not is_nil(dd),
    do: dd |> NaiveDateTime.to_iso8601()

  defp draft_deadline_value(%{competition_type: "grandmasters", competition: "gm_2021_1"}, _),
    do: gm_2021_1_start()

  defp draft_deadline_value(%{competition_type: "masters_tour", competition: ts_raw}, _),
    do: ts_raw |> TourStop.get_start_time()

  defp draft_deadline_value(%{competition_type: "masters_tour"}, _),
    do: TourStop.get_next() |> TourStop.get_start_time()

  defp draft_deadline_value(%{}, "grandmasters"), do: gm_2021_1_start()

  defp draft_deadline_value(%{}, "masters_tour"),
    do: current_tour_stop() |> TourStop.get_start_time()

  defp draft_deadline_value(_, _), do: nil

  defp update_draft_deadline(attrs = %{"deadline" => <<dd::binary>>}) do
    "#{dd}:00"
    |> NaiveDateTime.from_iso8601()
    |> case do
      {:ok, t} ->
        attrs |> Map.put("draft_deadline", t)

      {:error, _} ->
        Logger.warn("Could not parse draft_deadline: #{dd}")
        attrs
    end
  end

  defp update_draft_deadline(attrs), do: attrs

  def handle_event("change", params, socket) do
    {:noreply, socket |> assign_temp_vals(params)}
  end

  def handle_event(
        "submit",
        %{"league" => raw_attrs},
        socket = %{assigns: %{league: league = %{id: id}}}
      )
      when not is_nil(id) do
    attrs = raw_attrs |> update_draft_deadline()

    league
    |> Backend.Fantasy.update_league(attrs)
    |> handle_result(socket)
  end

  def handle_event("submit", %{"league" => attrs_raw}, socket) do
    {owner_id, attrs} =
      attrs_raw
      |> update_draft_deadline()
      |> add_round()
      |> Map.pop("owner_id")

    attrs
    |> Backend.Fantasy.create_league(owner_id)
    |> handle_result(socket)
  end

  def add_round(attrs) do
    attrs
    |> Map.put(
      "current_round",
      Backend.FantasyCompetitionFetcher.current_round(
        attrs["competition_type"],
        attrs["competition"]
      )
    )
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

  defp assign_temp_vals(socket, %{"league" => league_params}) do
    socket
    |> assign(:show_deadline, league_params["real_time_draft"] == "false")
    |> assign(:current_params, league_params)
  end

  defp string_to_bool("true"), do: true
  defp string_to_bool("false"), do: false
  defp string_to_bool(_), do: nil

  def reset_messages(socket), do: socket |> assign(show_error: false, show_succes: false)

  defp handle_result(result, socket) do
    assigns =
      case result do
        {:ok, _} ->
          [show_success: true, show_modal: false]

        {:error, error} ->
          Logger.warn("Error saving league #{error |> inspect()}", show_error: true)
      end

    {
      :noreply,
      socket
      |> reset_messages()
      |> assign(assigns)
    }
  end
end
