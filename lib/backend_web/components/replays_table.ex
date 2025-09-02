defmodule Components.ReplaysTable do
  @moduledoc false
  use Surface.Component
  alias Components.ExpandableDecklist
  alias Components.PlayerName
  alias Backend.Hearthstone.Deck
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Game
  alias Hearthstone.Enums.GameType
  alias Hearthstone.Enums.Format

  prop(replays, :list, required: true)
  prop(show_player_btag, :boolean, default: false)
  prop(show_deck, :boolean, default: true)
  prop(hide_deck_mobile, :boolean, default: false)
  prop(show_opponent, :boolean, default: true)
  prop(show_opponent_name, :boolean, default: false)
  prop(show_mode, :boolean, default: true)
  prop(show_result_as, :list, default: [:mode])
  prop(show_rank, :boolean, default: true)
  prop(show_replay_link, :boolean, default: true)
  prop(show_played, :boolean, default: true)

  def render(assigns) do
    ~F"""
      <table class="table is-fullwidth">
        <thead>
          <tr>
            <th :if={@show_player_btag}>Player</th>
            <th :if={@show_deck} class={"is-hidden-mobile": @hide_deck_mobile}>Deck</th>
            <th :if={@show_opponent}>Opponent</th>
            <th :if={@show_mode}>Game Mode</th>
            <th :if={@show_rank}>Rank</th>
            <th :if={@show_replay_link}>Replay Link</th>
            <th :if={@show_played}>Played</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={game <- @replays} >
            <td :if={@show_player_btag}><PlayerName flag={true} player={game.player_btag}/></td>
            <td class={"is-hidden-mobile": @hide_deck_mobile} :if={@show_deck and !!game.player_deck}><ExpandableDecklist id={"replay_decklist_#{game.id}"} deck={game.player_deck} /></td>
            <td class={"is-hidden-mobile": @hide_deck_mobile} :if={@show_deck and !game.player_deck}><div class="tag is-warning">Unknown or incomplete deck</div></td>
            <td :if={@show_opponent}>
              <span>
              {#if opponent_archetype = get_in(game, [Access.key(:played_cards, %{}), Access.key(:opponent_archetype, nil)])}
                <span class={"tw-text-black", "decklist-info", Deck.extract_class(opponent_archetype) |> String.downcase()}>{opponent_archetype}</span>
              {#else}
                <span class="icon">
                  <img src={"#{BackendWeb.BattlefyView.class_url(game.opponent_class)}"} >
                </span>
              {/if}
                <PlayerName :if={@show_opponent_name} player={game.opponent_btag}/>
              </span>
            </td>
            <td :if={@show_mode}> <p class={"tag", {class(game), :mode in @show_result_as}}>{game_mode(game)}</p></td>
            <td :if={@show_rank}><p class={"tag", {class(game), :rank in @show_result_as}}>{Game.player_rank_text(game)}</p></td>
            <td :if={@show_replay_link}><a :if={link = replay_link(game)} href={"#{link}"} target="_blank">View Replay</a></td>
            <td :if={@show_played}>{Timex.format!(game.inserted_at, "{relative}", :relative)}</td>
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
