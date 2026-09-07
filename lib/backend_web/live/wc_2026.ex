defmodule BackendWeb.WC2026Live do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.TournamentLineupExplorer

  data(has_lineups?, :boolean, default: false)
  data(show_bracket_predictions?, :boolean, default: false)
  data(battlefy_id, :string, default: nil)

  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> assign_defaults(session)
      |> put_user_in_context()
      |> assign_has_lineups()
      |> assign_info_from_bracket_predictions()
    }
  end

  def render(assigns) do
    ~F"""
      <.page_header title="Worlds 2026">
        <:nav_links>
          <a href="https://hearthstone.blizzard.com/news/24294372">
            Viewer Guide <HeroIcons.external_link />
          </a>
          <a :if={@battlefy_id} href={"/battlefy/tournament/#{@battlefy_id}"}>Tournament</a>
          <Components.Socials.twitch height={20} link="https://www.twitch.tv/playhearthstone" />
        </:nav_links>
        <:meta_info>
          <span class="is-hidden-mobile">Casters:  Edelweiss, Lorinda, PocketTrain, Raven, Sottle, and guests! </span>
        </:meta_info>
      </.page_header>
      <.alert :if={not_started?()} type="info" title="CYC">
        Don't forget to
        <a href="https://hearthstone.blizzard.com/vote/choose-your-champion" target="_blank">
          Choose Your Champion <HeroIcons.external_link />
        </a>
        <span :if={!@has_lineups?}>
          Though I would advise waiting for lineups :)
        </span>
      </.alert>
      <.alert :if={not_started?() and @show_bracket_predictions?} type="info" title="Bracket Prediction">
        <a href="/bracket-predictions/tournaments/1">
          Fill out
        </a> the bracket and potentially win a bundle for the next expansion! 
        <br>
        <sub>If at least 100 people fill out their bracket I'll giveaway a bundle for first place</sub>
      </.alert>
      <.accordion id="schedule_accoridan">
          <:trigger>
            <span>Day 1 (A-B) Initial & Winner matches - 6 Matches - <Helper.datetime datetime={~N[2026-09-08 16:00:00]} /></span>
          </:trigger>
          <:panel>
            <.tbd />
          </:panel>
          <:trigger>
            <span>Day 2 (C-D) Initial & Winner matches - 6 Matches - <Helper.datetime datetime={~N[2026-09-09 16:00:00]} /></span>
          </:trigger>
          <:panel>
            <.tbd />
          </:panel>
          <:trigger>
            <span>Day 3 (A-D) Elimination & Decider matches - 8 Matches - <Helper.datetime datetime={~N[2026-09-10 16:00:00]} /></span>
          </:trigger>
          <:panel>
            <.tbd />
          </:panel>
          <:trigger>
            <span>Day 4 Quarterfinals - 4 Matches - <Helper.datetime datetime={~N[2026-09-12 19:00:00]} /></span>
          </:trigger>
          <:panel>
            <.tbd />
          </:panel>
          <:trigger>
            <span>Day 5 Semis & Finals - 3 Matches - <Helper.datetime datetime={~N[2026-09-13 16:30:00]} /></span>
          </:trigger>
          <:panel>
            <.tbd />
          </:panel>
      </.accordion>
      <.accordion id="players_accordion">
        <:trigger>
          <span>Group A Players</span>
        </:trigger>
        <:panel>
          <div class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 xl:tw-grid-cols-4">
            <.player_img alt="McBanterFace"/>
            <.player_img alt="Soyorin"/>
            <.player_img alt="mlYanming"/>
            <.player_img alt="hyosung"/>
          </div>
        </:panel>
        <:trigger>
          <span>Group B Players</span>
        </:trigger>
        <:panel>
          <div class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 xl:tw-grid-cols-4">
            <.player_img alt="maxiebon1234" image_part="maxiebon" />
            <.player_img alt="WinBrownie"/>
            <.player_img alt="XiaoT"/>
            <.player_img alt="Fatty"/>
          </div>
        </:panel>
        <:trigger>
          <span>Group C Players</span>
        </:trigger>
        <:panel>
          <div class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 xl:tw-grid-cols-4">
            <.player_img alt="Gaby59" image_part="gaby" />
            <.player_img alt="Curfew"/>
            <.player_img alt="Xiaobai"/>
            <.player_img alt="Kwanuu"/>
          </div>
        </:panel>
        <:trigger>
          <span>Group D Players</span>
        </:trigger>
        <:panel>
          <div class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 xl:tw-grid-cols-4">
            <.player_img alt="OTGxhh"/>
            <.player_img alt="Che0nsu"/>
            <.player_img alt="SAVOR"/>
            <.player_img alt="Mesmile"/>
          </div>
        </:panel>
      </.accordion>
      <TournamentLineupExplorer :if={@has_lineups?} id={"wc_2026_lineups"} tournament_id={"wc_2026"} tournament_source={"hsesports"} />
      <br>
      <.alert :if={!@has_lineups?} title="Lineups">
        Lineups aren't out yet or haven't been added to the site yet. Lineups will be available here soon after the deadline
      </.alert>
    """
  end

  defp assign_has_lineups(socket) do
    has_lineups = Backend.Hearthstone.has_lineups?("wc_2026", "hsesports")

    socket
    |> assign(has_lineups: has_lineups)
  end

  attr :alt, :string, required: true
  attr :image_part, :string, default: nil

  def player_img(assigns) do
    ~H"""
    <div class="tw-flex-col">
      <img class="image tw-rounded-md tw-p-4" alt={@alt} src={"/images/worlds_2026/#{@image_part || String.downcase(@alt)}.jpg"} />
    </div>
    """
  end

  def tbd(assigns) do
    ~H"""
    <.alert title="TBD" type="info">
      The exact match schedule is To Be Determined
    </.alert>
    """
  end

  defp not_started?, do: Util.after_now?(~N[2026-09-08 16:00:00])

  defp assign_info_from_bracket_predictions(socket) do
    new_assigns =
      Backend.BracketPredictions.get_tournament(1)
      |> assigns_from_bracket_predictions()

    socket
    |> assign(new_assigns)
  end

  defp assigns_from_bracket_predictions(%Backend.BracketPredictions.Tournament{} = tournament) do
    [
      show_bracket_predictions?: tournament.status == "open",
      battlefy_id: tournament.battlefy_tournament_id
    ]
  end

  defp assigns_from_bracket_predictions(_) do
    [show_bracket_prediciton?: false, battlefy_id: false]
  end
end
