defmodule Components.ReplaysTable do
  @moduledoc false
  use Surface.Component
  alias Components.ExpandableDecklist
  alias Hearthstone.DeckTracker
  alias Hearthstone.Enums.GameType
  alias Hearthstone.Enums.Format

  prop(replays, :list, required: true)
  def render(assigns) do
    ~F"""
      <table class="table is-fullwidth">
        <thead>
          <tr>
            <th>Deck</th>
            <th>Opponent</th>
            <th>Game Mode</th>
            <th>Replay Link</th>
            <th>Played</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={game <- @replays} class={class(game)} >
            <td><ExpandableDecklist id={"replay_decklist_#{game.id}"} deck={game.player_deck} guess_archetype={true}/></td>
            <td>
              <span>
                <span class="icon">
                  <img src={"#{BackendWeb.BattlefyView.class_url(game.opponent_class)}"} >
                </span>
                {game.opponent_btag}
              </span>
            </td>
            <td>{game_mode(game)}</td>
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
  def class(%{status: :won}), do: "game-won"
  def class(%{status: :lost}), do: "game-lost"
  def class(_), do: ""
end
