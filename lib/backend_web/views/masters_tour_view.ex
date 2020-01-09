defmodule BackendWeb.MastersTourView do
  use BackendWeb, :view
  alias Backend.MastersTour.InvitedPlayer

  def render("qualifiers.html", %{fetched_qualifiers: qualifiers_raw}) do
    qualifiers =
      qualifiers_raw
      |> Enum.map(fn q -> Map.put_new(q, :link, create_qualifier_link(q.slug, q.id)) end)

    render("qualifiers.html", %{qualifiers: qualifiers})
  end

  def render("invited_players.html", %{invited: invited}) do
    invited_players = Enum.map(invited, &process_invited_player/1)
    render("invited_players.html", %{invited_players: invited_players})
  end

  @spec process_invited_player(%{battletag_full: binary, reason: any}) :: %{
          battletag: binary,
          link: nil | <<_::64, _::_*8>>,
          reason: any
        }
  def process_invited_player(invited_player = %{battletag_full: battletag_full, reason: reason}) do
    link =
      case invited_player do
        %{tournament_slug: slug, tournament_id: id} when slug != nil and id != nil ->
          create_qualifier_link(slug, id)

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

  @spec create_qualifier_link(String.t(), String.t()) :: String.t()
  def create_qualifier_link(slug, id) do
    "https://battlefy.com/hsesports/#{slug}/#{id}/info"
  end
end
