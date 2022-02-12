defmodule Components.ReplaysTable do
  @moduledoc false
  use Surface.Component
  alias Components.ExpandableDecklist
  alias Components.PlayerName
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Game
  alias Hearthstone.Enums.GameType
  alias Hearthstone.Enums.Format
  alias BackendWeb.Router.Helpers, as: Routes

  prop(replays, :list, required: true)
  def render(assigns) do
    ~F"""
      <table class="table is-fullwidth">
        <thead>
          <tr>
            <th>Deck</th>
            <th>Opponent</th>
            <th>Game Mode</th>
            <th>Rank</th>
            <th>Replay Link</th>
            <th>Played</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={game <- @replays} >
            <td :if={game.player_deck}><ExpandableDecklist id={"replay_decklist_#{game.id}"} deck={game.player_deck} guess_archetype={true}/></td>
            <td :if={!game.player_deck}><div class="tag is-warning">Unknown or incomplete deck</div></td>
            <td>
              <span>
                <span class="icon">
                  <img src={"#{BackendWeb.BattlefyView.class_url(game.opponent_class)}"} >
                </span>
                <PlayerName flag={true} text_link={Routes.player_path(BackendWeb.Endpoint, :player_profile, game.opponent_btag)} player={game.opponent_btag}/>
              </span>
            </td>
            <td><p class={"tag", class(game)}>{game_mode(game)}</p></td>
            <td>{Game.player_rank_text(game)}</td>
            <td><a href={"#{replay_link(game)}"} target="_blank">View Replay</a></td>
            <td>{Timex.format!(game.inserted_at, "{relative}", :relative)}</td>
          </tr>
        </tbody>
      </table>
    """
  end

  def game_mode(%{game_type: game_type, format: format}) do
    if game_type in [GameType.ranked(), GameType.casual()] do
      "#{GameType.name(game_type)} #{Format.name(format)}"
    else
      "#{GameType.name(game_type)}"
    end
  end

  def game_mode(_), do: ""
  def replay_link(game), do: DeckTracker.replay_link(game)
  def class(%{status: :win}), do: "is-success"
  def class(%{status: :loss}), do: "is-danger"
  def class(_), do: "is-info"
end
