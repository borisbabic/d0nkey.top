defmodule BackendWeb.MastersTourView do
  use BackendWeb, :view
  alias Backend.MastersTour.InvitedPlayer

  def render("invited_players.html", %{invited: invited}) do
    invited_players = Enum.map(invited, &process_invited_player/1)
    render("invited_players.html", %{invited_players: invited_players})
  end

  def process_invited_player(invited_player = %{battletag_full: battletag_full, reason: reason}) do
    link =
      case invited_player do
        %{tournament_slug: ts, tournament_id: ti} when ts != nil and ti != nil ->
          "https://battlefy.com/hsesports/#{ts}/#{ti}/info"

        _ ->
          nil
      end

    battletag = InvitedPlayer.shorten_battletag(battletag_full)

    %{
      link: link,
      reason: reason,
      battletag: battletag
    }
  end
end
