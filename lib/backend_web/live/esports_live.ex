defmodule BackendWeb.EsportsLive do
  @moduledoc "/esports"
  use BackendWeb, :surface_live_view
  alias FunctionComponents.EsportsBadges
  data(user, :any)

  def mount(_params, session, socket) do
    {:ok, socket |> assign_defaults(session) |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
    <div>
      <div class="title is-2">Esports</div>
          <li></li>
      <div class="subtitle is-6">
        <a href={~p"/mt/tour-stops"}>Tour Stops</a>
        | <a href={~p"/legacy-hsesports"}>Legacy HSEsports</a>
        <span>| This page is WIP, if you have ideas <a href={~p"/discord"}>let me know</a> </span>
      </div>
      <div class="columns is-narrow is-multiline is-mobile">
        <div class="column">
          <.hsesports_card />
        </div>
        <div class="column">
          <.thl_card />
        </div>
        <div class="column">
          <.jungle_card />
        </div>
      </div>
    </div>
    """
  end

  def hsesports_card(assigns) do
    ~H"""
     <div class="card tw-width-200">
       <div class="card-content">
         <div class="media">
           <div class="media-content">
             <a class="title is-4" href="https://hearthstone.blizzard.com/news/24180851/hearthstone-esports-is-back-in-2025">HSEsports!</a>
             <br>
             <a class="subtitle is-6" href="https://x.com/playhearthstone">@PlayHearthstone</a>
           </div>
         </div>
         <div class="content">
           <EsportsBadges.badges badges={[:AM, :EU, :AP, :standard, :bo3, :open, :free]} />
           Official HSEsports! Qualify through open qualifiers or <a href="/leaderboard/points">Ladder Points</a>
         </div>
       </div>
     </div>
    """
  end

  def thl_card(assigns) do
    ~H"""
     <div class="card tw-width-200">
       <div class="card-content">
         <div class="media">
           <div class="media-left">
               <img class="has-ratio" height="48" width="36" src="https://www.teamhearthleague.com/uploads/4/2/5/5/42557845/card-large.png"/>
           </div>
           <div class="media-content">
             <a class="title is-4" href="https://www.teamhearthleague.com/">Team Hearth League</a>
             <br>
             <a class="subtitle is-6" href="https://x.com/thl_hs">@thl_hs</a>
           </div>
         </div>
         <div class="content">
           <EsportsBadges.badges badges={[:AM, :standard, :wild, :battlegrounds, :bo5, :open, :closed, :team, :free]} />
           One match per week, scheduled with your opponent. Season starts soon so sign up! (no prizes)
         </div>
       </div>
     </div>
    """
  end

  def jungle_card(assigns) do
    ~H"""
      <div class="card tw-width-200">
        <div class="card-content">
          <div class="media">
            <%!-- <div class="media-left">
                <img class="has-ratio" height="48" width="36" src="https://www.teamhearthleague.com/uploads/4/2/5/5/42557845/card-large.png"/>
            </div> --%>
            <div class="media-content">
              <a class="title is-4" href="https://discord.com/invite/vz8DcuN45m">Jungle Championship</a>
              <br>
              <a class="subtitle is-6" href="https://x.com/LegendBonobo">@LegendBonobo</a>
            </div>
          </div>
          <div class="content">
            <EsportsBadges.badges badges={[:EU, :standard, :open, :solo, :free]} />
            Qualifiers, LANs, and ladder!
          </div>
        </div>
      </div>
    """
  end
end
