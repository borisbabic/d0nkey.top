defmodule BackendWeb.AdminPanelLive do
  use BackendWeb, :surface_live_view
  alias Backend.UserManager.User
  alias Surface.Components.Form
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.NumberInput
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Submit

  data(user, :any)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
    <div>
      <div class="title is-2">Welcome Handsome💖</div>
      <br>
      <div :if={User.can_access?(@user, :deck)}>

        <div class="subtitle is-4">
          Update decks for archetypes period
        </div>
        <Form for={%{}} submit="update_archetypes">
          <Label class="label">Period</Label>
          <TextInput field={"period"} class="input has-text-black" opts={placeholder: "Period"}/>
          <Submit label="Update" class="button" />
        </Form>
      </div>
      <br>
      <div :if={User.can_access?(@user, :leaderboards)}>
        <div class="subtitle is-4">
          Save all leaderboards with delay
        </div>
        Comma separate for multiple values
        <Form for={%{}} submit="save_all_with_delay">
          <Label class="label">LDB id</Label>
          <TextInput field={"leaderboard_id"} class="input has-text-black" opts={placeholder: "Leaderboard"}/>
          <Label class="label">Region</Label>
          <TextInput field={"region"} class="input has-text-black" opts={placeholder: "Region"}/>
          <Label class="label">Season</Label>
          <TextInput field={"season_id"} class="input has-text-black" opts={placeholder: "Season ID"}/>
          <Label class="label">Delay MS</Label>
          <NumberInput label={"delay ms"} field={"delay"} value={1000} class="input has-text-black" opts={placeholder: "Delay ms"}/>
          <Submit label="Save" class="button" />
        </Form>
      </div>
      <br>
    </div>
    """
  end

  def handle_event("update_archetypes", %{"period" => period}, socket) do
    do_async(fn ->
      Backend.Hearthstone.recalculate_decks_archetypes_for_period(period)
    end)

    {:noreply, socket}
  end

  def handle_event(
        "save_all_with_delay",
        %{
          "leaderboard_id" => ldb_id_raw,
          "region" => region_raw,
          "season_id" => season_id_raw,
          "delay" => delay
        },
        socket
      ) do
    ldb_ids = split_string(ldb_id_raw)
    regions = split_string(region_raw)

    season_ids =
      split_string(season_id_raw)
      |> Enum.map(&Util.to_int_or_orig/1)
      |> Enum.filter(&is_integer/1)

    do_async(fn ->
      for l <- ldb_ids, r <- regions, s <- season_ids do
        season = %Hearthstone.Leaderboards.Season{
          season_id: s,
          leaderboard_id: l,
          region: r
        }

        Backend.Leaderboards.save_all_with_delay(season, delay)
      end
    end)

    {:noreply, socket}
  end

  defp split_string(string) do
    String.split(string, ",") |> Enum.map(&String.trim/1) |> Enum.filter(&(&1 && &1 != ""))
  end

  defp do_async(fun) do
    Task.Supervisor.async_nolink(Backend.TaskSupervisor, fun)
  end
end
