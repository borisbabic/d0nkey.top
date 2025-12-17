defmodule BackendWeb.WC2025Live do
  @moduledoc "Page for 2025 worlds"

  use BackendWeb, :surface_live_view

  alias Components.TournamentLineupExplorer
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Components.Helper
  alias Components.CompactLineup

  data(user, :any)
  data(lineup_map, :any, default: %{})

  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> assign_defaults(session)
      |> put_user_in_context()
      # |> assign_lineup_map()
    }
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2"> Worlds 2025</div>
        <div class="subtitle is-6 tw-flex">
        <a href={~p"/tournament-lineups/hsesports/worlds-2025/popularity"}>Popularity</a>
        | <Components.Socials.twitch height={20} link="https://www.twitch.tv/hearthstone" />
        <span class="is-hidden-mobile">|Casters:  Edelweiss, Lorinda, Raven, Sottle | Guests: Cora, Darroch, McBanterFace, Reqvam</span>
        <span class="is-hidden-mobile">|<a href="https://hearthstone.blizzard.com/en-us/news/24244454/get-ready-for-the-2025-hearthstone-world-championship">Viewer Guide</a></span>
        <span class={cyc_class()}>|<a href="https://hearthstone.blizzard.com/vote/choose-your-champion">Choose Your Champion</a></span>
        </div>

        <.accordion id="schedule_accordian">
          <:trigger>
            <span>Day 1 (A-B) - 6 Matches - <Helper.datetime datetime={~N[2025-12-18 15:00:00]} /></span>
          </:trigger>
          <:panel>
            <ol>
              <li class="tw-flex">Group A - Definition <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "Definition")} lineup={l} /> vs. XiaoT <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "XiaoT")} lineup={l} /></li>
              <li class="tw-flex">Group A - PocketTrain <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "PocketTrain")} lineup={l} /> vs. Tansoku <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "Tansoku")} lineup={l} /></li>
              <li class="tw-flex">Group A - Winners Match</li>
              <br/>

              <li class="tw-flex">Group B - iNS4NE <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "iNS4NE")} lineup={l} /> vs. Soyorin <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "Soyorin")} lineup={l} /></li>
              <li class="tw-flex">Group B - mlYanming <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "mlYanming")} lineup={l} /> vs. Che0nsu <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "Che0nsu")} lineup={l} /></li>
              <li class="tw-flex">Group B - Winners Match</li>
            </ol>
          </:panel>
          <:trigger>
            <span>Day 2 (C-D) - 6 Matches - <Helper.datetime datetime={~N[2025-12-19 15:00:00]} /></span>
          </:trigger>
          <:panel>
            <ol>
              <li class="tw-flex">Group C - LoveStorm <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "LoveStorm")} lineup={l} /> vs. gyu <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "gyu")} lineup={l} /></li>
              <li class="tw-flex">Group C - Gaby59 <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "Gaby59")} lineup={l} /> vs. FilFeel <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "FilFeel")} lineup={l} /></li>
              <li class="tw-flex">Group C - Winners Match</li>
              <br/>
              <li class="tw-flex">Group D - Tianming <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "Tianming")} lineup={l} /> vs. Incurro <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "Incurro")} lineup={l} /></li>
              <li class="tw-flex">Group D - Maxiebon1234 <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "Maxiebon1234")} lineup={l} /> vs. Furyhunter <CompactLineup id={Ecto.UUID.generate()} :if={l = Map.get(@lineup_map, "Furyhunter")} lineup={l} /></li>
              <li class="tw-flex">Group D - Winners Match</li>
            </ol>
          </:panel>
          <:trigger>
            <span>Day 3 (A-D) - 8 Matches - <Helper.datetime datetime={~N[2025-12-20 15:00:00]} /></span>
          </:trigger>
          <:panel>
            Elimination and Decider Matches for all Groups
          </:panel>
          <:trigger>
            <span>Day 4 (Top 8) - 6 Matches - <Helper.datetime datetime={~N[2025-12-21 15:00:00]} /></span>
          </:trigger>
          <:panel>
            Quarterfinals, Semifinals, and Finals
          </:panel>
        </.accordion>

        <br>
        <br>

        <TournamentLineupExplorer id={"wc_2025"} tournament_id={"worlds-2025"} tournament_source={"hsesports"} />
      </div>
    """
  end

  defp cyc_class() do
    now = NaiveDateTime.utc_now()

    if NaiveDateTime.compare(now, ~N[2025-12-18 14:00:00]) == :gt do
      "is-hidden-mobile"
    else
      ""
    end
  end

  defp assign_lineup_map(socket) do
    lineup_map =
      TournamentLineupExplorer.lineups("worlds-2025", "hsesports")
      |> Map.new(fn lineup ->
        key = String.replace(lineup.display_name, ~r/Group . - /, "")
        {key, lineup}
      end)

    assign(socket, lineup_map: lineup_map)
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}
end
