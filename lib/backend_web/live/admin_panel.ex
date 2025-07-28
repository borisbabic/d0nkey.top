defmodule BackendWeb.AdminPanelLive do
  use BackendWeb, :surface_live_view
  alias Backend.UserManager.User

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
        <.form for={%{}} id="update_archetypes_form" phx-submit="update_archetypes">
          <label class="label" for="period">Period</label>
          <input class="input has-text-black" type="text" name="period" id="period" placeholder="Period"/>
          <button type="submit" class="button">Update</button>
        </.form>
      </div>
      <br>
      <div :if={User.can_access?(@user, :leaderboards)}>
        <div class="subtitle is-4">
          Save all leaderboards with delay
        </div>
        Comma separate for multiple values
        <.form for={%{}} id="save_all_with_delay_form" phx-submit="save_all_with_delay">
          <label class="label" for="leaderboard_id">LDB id</label>
          <input class="input has-text-black" type="text" name="leaderboard_id" id="leaderboard_id" placeholder="Leaderboard"/>
          <label class="label" for="region">Region</label>
          <input class="input has-text-black" type="text" name="region" id="region" placeholder="Region"/>
          <label class="label" for="season_id">Season</label>
          <input class="input has-text-black" type="text" name="season_id" id="season_id" placeholder="Season ID"/>
          <label class="label" for="delay">Delay MS</label>
          <input class="input has-text-black" type="number" name="delay" id="delay" value="1000" placeholder="Delay ms"/>
          <button type="submit" class="button">Save</button>
        </.form>
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
