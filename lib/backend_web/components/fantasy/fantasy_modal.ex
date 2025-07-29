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
  data(competition_type, :string)
  prop(user, :map, from_context: :user)

  alias Backend.LobbyLegends.LobbyLegendsSeason
  import BackendWeb.FantasyHelper
  alias Backend.Fantasy
  alias Backend.MastersTour.TourStop

  def render(assigns) do
    competition_type = selected_competition_type(assigns.current_params, assigns.league)
    assigns = assigns |> assign(competition_type: competition_type)

    ~F"""
    <div>
      <button class="button" type="button" :on-click="show_modal">{@title}</button>
      <div :if={@show_success} class="notification is-success tag">{@success_message}</div>
      <div class="modal is-active" :if={@show_modal}>
        <.form for={%{}} as={:league} id="fantasy_league_form" phx-change="change" phx-submit="submit" phx-target={@myself}>
          <div class="modal-background"></div>
          <div class="modal-card">
            <header class="modal-card-head">
              <p class="modal-card-title">{@title}</p>
              <button class="delete" type="button" aria-label="close" :on-click="hide_modal"></button>
            </header>
            <section class="modal-card-body">
              <div class="field">
                <label class="label" for="name">Name</label>
                <input
                  class="input has-text-black is-small"
                  type="text"
                  name="league[name]"
                  id="name"
                  value={@current_params["name"] || @league.name}
                />
              </div>
              <div class="field">
                <label class="label" for="max_teams">Max Teams</label>
                <input
                  class="input has-text-black is-small"
                  type="number"
                  name="league[max_teams]"
                  id="max_teams"
                  value={@current_params["max_teams"] || @league.max_teams}
                />
              </div>
              <div class="field">
                <label class="label" for="roster_size">Roster Size</label>
                <input
                  class="input has-text-black is-small"
                  type="number"
                  name="league[roster_size]"
                  id="roster_size"
                  value={@current_params["roster_size"] || @league.roster_size}
                />
              </div>
              <div class="field">
                <label class="label" for="competition_type">Competition Type</label>
                <select
                  class="select has-text-black"
                  name="league[competition_type]"
                  id="competition_type"
                  value={@competition_type}
                >
                  <option :for={{label, value} <- competition_type_options()} value={value} selected={value == @competition_type}>{label}</option>
                </select>
              </div>
              <div class="field" :if={@competition_type != "battlefy"}>
                <label class="label" for="competition">Competition</label>
                <select
                  class="select has-text-black"
                  name="league[competition]"
                  id="competition"
                  value={@current_params["competition"] || @league.competition}
                >
                  <option :for={{label, value} <- competition_options(@competition_type)} value={value} selected={value == (@current_params["competition"] || @league.competition)}>{label}</option>
                </select>
              </div>
              <div class="field" :if={@competition_type == "battlefy"}>
                <label class="label" for="battlefy_tournament_id">Battlefy tournament id</label>
                <input
                  class="input has-text-black is-small"
                  type="text"
                  name="league[competition]"
                  id="battlefy_tournament_id"
                  value={(@current_params["competition"] || @league.competition) |> battlefy_tournament_id()}
                />
              </div>
              <div class="field" :if={@competition_type == "grandmasters"}>
                <label class="label" for="changes_between_rounds">Changes Between Rounds</label>
                <input
                  class="input has-text-black is-small"
                  type="number"
                  name="league[changes_between_rounds]"
                  id="changes_between_rounds"
                  value={@current_params["changes_between_rounds"] || @league.changes_between_rounds}
                />
              </div>
              <div class="field">
                <label class="label" for="real_time_draft">Real Time Draft</label>
                <input
                  type="checkbox"
                  name="league[real_time_draft]"
                  id="real_time_draft"
                  value="true"
                  checked={@current_params["real_time_draft"] || @league.real_time_draft}
                />
              </div>
              <div class="field" :if={@league.draft_deadline || !@league.real_time_draft || @show_deadline}>
                <label class="label" for="deadline">Draft Deadline (UTC!)</label>
                <input
                  type="datetime-local"
                  name="league[deadline]"
                  id="deadline"
                  value={@current_params["deadline"] || draft_deadline_value(@league, @competition_type)}
                />
              </div>
              <div class="field">
                <label class="label" for="point_system">Point System</label>
                <select
                  class="select has-text-black"
                  name="league[point_system]"
                  id="point_system"
                  value={@current_params["point_system"] || @league.point_system}
                >
                  <option :for={{label, value} <- point_system_options(@competition_type)} value={value} selected={value == (@current_params["point_system"] || @league.point_system)}>{label}</option>
                </select>
              </div>
              <div class="field" :if={@league.join_code}>
                <label class="label" for="join_code">Join Code</label>
                {@league.join_code}
                <button class="button" type="button" :on-click="regenerate_join_code">Regenerate</button>
                <input type="hidden" name="league[join_code]" value={@league.join_code} />
              </div>
              <input type="hidden" name="league[owner_id]" value={@user.id} />
            </section>
            <footer class="modal-card-foot">
              <button type="submit" class="button is-success">Save</button>
              <button class="button" type="button" :on-click="hide_modal">Cancel</button>
              <div :if={@show_error} class="notification is-warning tag">{@error_message}</div>
            </footer>
          </div>
        </.form>
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

  defp current_lobby_legends(), do: LobbyLegendsSeason.current(120, 0)

  defp current_tour_stop(), do: TourStop.get_current(120, 0)
  defp current_tour_stop?(), do: nil != current_tour_stop()

  defp competition_type_options() do
    if current_tour_stop?() do
      [{"Masters Tour", "masters_tour"}]
    else
      []
    end
    |> add_card_nerfs()
    |> add_lobby_legends()
    |> Kernel.++([
      {"Grandmasters", "grandmasters"},
      {"Battlefy", "battlefy"}
    ])
  end

  defp add_card_nerfs(previous) do
    if current_card_nerfs?() do
      [{"Card Nerfs", "card_nerfs"} | previous]
    else
      previous
    end
  end

  defp current_card_nerfs?() do
    today = Date.utc_today()
    Date.compare(today, ~D[2022-08-03]) == :lt
  end

  defp add_lobby_legends(competition_types) do
    if current_lobby_legends() do
      [{"Lobby Legends", "lobby_legends"} | competition_types]
    else
      competition_types
    end
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

  defp competition_options("grandmasters"), do: ["gm_2022_2"] |> competition_options()

  defp competition_options("masters_tour") do
    current_tour_stop()
    |> case do
      nil -> []
      id -> [id] |> competition_options()
    end
  end

  defp competition_options("lobby_legends") do
    case current_lobby_legends() do
      nil -> []
      %{slug: slug} -> [slug] |> competition_options()
    end
  end

  defp competition_options("card_nerfs") do
    ["murder-at-castle-nathria"]
  end

  defp competition_options(competitions) when is_list(competitions),
    do: competitions |> Enum.map(&{&1 |> competition_name(), &1})

  defp competition_options(_), do: []

  defp point_system_options("grandmasters"), do: ["total_wins"] |> point_system_options()

  defp point_system_options("lobby_legends"),
    do: ["total_points"] |> point_system_options()

  defp point_system_options("masters_tour"),
    do: ["swiss_wins", "gm_points_2021"] |> point_system_options()

  defp point_system_options("battlefy"),
    do: ["swiss_wins"] |> point_system_options()

  defp point_system_options("card_nerfs"),
    do: ["3_new_1_old"] |> point_system_options()

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

  defp draft_deadline_value(%{competition_type: "lobby_legends", competition: ll_raw}, _) do
    case LobbyLegendsSeason.get(ll_raw) do
      %{start_time: start_time} when not is_nil(start_time) -> start_time
      _ -> nil
    end
  end

  defp draft_deadline_value(%{}, "grandmasters"), do: gm_2021_1_start()

  defp draft_deadline_value(%{}, "masters_tour"),
    do: current_tour_stop() |> TourStop.get_start_time()

  defp draft_deadline_value(%{}, "lobby_legends") do
    case current_lobby_legends() do
      %{start_time: start_time} -> start_time
      _ -> nil
    end
  end

  defp draft_deadline_value(_, _), do: nil

  defp update_draft_deadline(attrs = %{"deadline" => <<dd::binary>>}) do
    "#{dd}:00"
    |> NaiveDateTime.from_iso8601()
    |> case do
      {:ok, t} ->
        attrs |> Map.put("draft_deadline", t)

      {:error, _} ->
        Logger.warning("Could not parse draft_deadline: #{dd}")
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

  defp assign_temp_vals(socket, %{"league" => league_params}) do
    socket
    |> assign(:show_deadline, league_params["real_time_draft"] == "false")
    |> assign(:current_params, league_params)
  end

  def reset_messages(socket), do: socket |> assign(show_error: false, show_success: false)

  defp handle_result(result, socket) do
    assigns =
      case result do
        {:ok, _} ->
          [show_success: true, show_modal: false]

        {:error, error} ->
          Logger.warning("Error saving league #{error |> inspect()}")
      end

    {
      :noreply,
      socket
      |> reset_messages()
      |> assign(assigns)
    }
  end
end
