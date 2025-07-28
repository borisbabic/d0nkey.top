defmodule BackendWeb.LineupSubmitterLive do
  use BackendWeb, :surface_live_view

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
          <.form for={%{}} as={:lineups} id="lineup_submit_form" phx-submit="submit">
            <div class="field">
              <label class="label" for="tournament_id">Tournament ID/name</label>
              <input class="input has-text-black is-small" type="text" name="lineups[tournament_id]" id="tournament_id" />
            </div>
            <div class="field" :if={custom_tournament_source?(@user)}>
              <label class="label" for="tournament_source">Tournament Source (like organization or website)</label>
              <input class="input has-text-black is-small" type="text" name="lineups[tournament_source]" id="tournament_source" value={@user.battletag} />
            </div>
            <div class="field">
              <label class="label" for="csv">CSV of lineups: name,link or name,deck1,deck2,deck...</label>
              <textarea class="has-text-black" name="lineups[csv]" id="csv"></textarea>
            </div>
            <div class="field" :if={false}>
              <label class="label" for="gid">gid taken from the url with the specific sheet open (EMPTY => LEFTMOST sheet)</label>
              <input class="input has-text-black small" type="text" name="lineups[gid]" id="gid" />
            </div>
            <div class="field" :if={false}>
              <label class="label" for="sheet_id">Sheet id from the google sheets url</label>
              <input class="input has-text-black small" type="text" name="lineups[sheet_id]" id="sheet_id" />
            </div>
            <div class="field" :if={false}>
              <label class="label" for="ignore_columns">Ignore Columns (first non ignored column should be the name then the rest should be decks)</label>
              <input class="input has-text-black" type="number" name="lineups[ignore_columns]" id="ignore_columns" value="1" />
            </div>
            <button type="submit" class="button is-success">Save Lineups</button>
            <div :if={@view_url}>
              View lineups <a href={@view_url}>Here</a>
            </div>
          </.form>
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

  def csv_url(%{"sheet_id" => sheet_id} = attrs) do
    "https://docs.google.com/spreadsheets/d/#{sheet_id}/export?format=csv"
    |> append_gid(attrs)
  end

  defp append_gid(url, %{"gid" => ""}), do: url
  defp append_gid(url, %{"gid" => gid}), do: url <> "&gid=#{gid}"
end
