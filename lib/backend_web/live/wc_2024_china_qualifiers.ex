defmodule BackendWeb.WC2024ChinaQualifiers do
  use BackendWeb, :surface_live_view
  alias Components.TournamentLineupExplorer
  alias Backend.DeckInteractionTracker, as: Tracker
  data(user, :any)
  data(tournament_id, :string)
  data(tournament_source, :string)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <div>
        <div>
          <div class="title is-2">WC 2024 China Qualifiers</div>
          <div class="subtitle is-5">
            <a href="https://docs.google.com/spreadsheets/d/1cx0D_UOucIRBs_h4BtUqcPjA5X_tGtPhKdB946GMJzs">Info</a> |
            <a href="https://www.huya.com/blizzardgame1">Huya</a> |
            <a href="https://www.douyu.com/1024">Douyu</a> |
            <a href="https://live.bilibili.com/3683436">Bilibili</a>
          </div>
          <FunctionComponents.Ads.below_title/>
          <TournamentLineupExplorer id={"tournament_lineup_explorer_wc_2024_china_qualifiers"} tournament_id={"china-qualifiers"} tournament_source={"worlds-2024"} />
        </div>
      </div>
    """
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
