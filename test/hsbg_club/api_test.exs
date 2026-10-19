defmodule HSBGClub.ApiTest do
  use ExUnit.Case, async: true
  alias HSBGClub.Api
  alias HSBGClub.Tournament

  @html """
  <table class="ledger" id="Upcoming">
    <tr class="ledger-head">
      <th scope="col">Tournament Number</th><th scope="col">Tournament Name</th><th scope="col">Date</th><th scope="col">Mode</th><th scope="col">Max Players</th><th scope="col">Tournament Type</th><th scope="col">Prize (USD)</th><th scope="col">&nbsp;</th>
    </tr><tr class="ledger-row">
      <td>911</td><td>Qualy TCK #9</td><td>11/7/2026 8:00:00 PM</td><td>Solo</td><td>64</td><td>Free</td><td>15</td><td>
        <input type="submit" name="Upcoming$ctl02$ViewButton2" value="View Details" />
      </td>
    </tr><tr class="ledger-row-alt">
      <td>875</td><td>PRE TORNEO 1</td><td>10/12/2024 3:15:00 AM</td><td>Duos</td><td>16</td><td>Free</td><td>30</td><td></td>
    </tr><tr class="ledger-pager">
      <td colspan="8"><table><tr><td><span>1</span></td><td><a href="#">2</a></td></tr></table></td>
    </tr>
  </table>
  """

  test "parses tournament rows and skips header and pager rows" do
    {:ok, document} = Floki.parse_document(@html)

    assert [
             %Tournament{
               id: "911",
               name: "Qualy TCK #9",
               date: ~N[2026-11-07 20:00:00],
               mode: "Solo",
               max_players: 64,
               type: "Free",
               prize: "15"
             },
             %Tournament{id: "875", date: ~N[2024-10-12 03:15:00], mode: "Duos"}
           ] = Api.parse_tournaments(document)
  end

  test "links to the info page before the tournament starts and the score sheet after" do
    upcoming = %Tournament{id: "911", date: ~N[2999-01-01 00:00:00]}
    previous = %Tournament{id: "875", date: ~N[2024-10-12 03:15:00]}

    assert Tournament.standings_link(upcoming) ==
             "https://hsbgclub.com/TournamentInfo?TourneyID=911"

    assert Tournament.standings_link(previous) ==
             "https://hsbgclub.com/TournamentScore?TourneyID=875"
  end
end
