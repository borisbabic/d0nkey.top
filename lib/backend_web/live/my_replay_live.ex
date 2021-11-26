defmodule BackendWeb.MyReplaysLive do
  @moduledoc false
  use Surface.LiveView
  alias Components.ExpandableDecklist
  alias Backend.UserManager.User
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.Game
  alias Hearthstone.Enums.GameType
  alias Hearthstone.Enums.Format
  import BackendWeb.LiveHelpers

  data(user, :any)
  data(limit, :any)
  data(offset, :any)

  @default_limit 25
  @default_offset 0

  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns) do
    # filters
    # player class
    # opponent class
    # player rank
    # region
    ~H"""
    <Context put={{ user: @user }}>
      <div class="container">
        <div class="level">
          <div class="level-item title is-2">My Replays</div>
        </div>
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
            <tr :for={{ game <- games(@user, @limit, @offset) }} class="{{class(game)}}" >
              <td><ExpandableDecklist id={{ "replay_decklist_#{game.id}" }} deck={{ game.player_deck }} guess_archetype={{ true }}/></td>
              <td>
                <span>
                  <span class="icon">
                    <img src="{{ BackendWeb.BattlefyView.class_url(game.opponent_class) }}" >
                  </span>
                  {{ game.opponent_btag }}
                </span>
              </td>
              <td>{{ game_mode(game) }}</td>
              <td><a href="{{ replay_link(game) }}" target="_blank">View Replay</a></td>
              <td>{{ Timex.format!(game.inserted_at, "{relative}", :relative) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </Context>
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

  @default_limit 25
  @spec limit(String.t() | integer()) :: integer()
  def limit(l) when is_binary(l) do
    case Integer.parse(l) do
      {l, _} -> limit(l)
      _ -> @default_limit
    end
  end
  def limit(l) when is_integer(l), do: Enum.min([l, 100])
  def limit(_), do: @default_limit

  @default_limit 25
  @spec offset(String.t() | integer()) :: integer()
  def offset(l) when is_binary(l) do
    case Integer.parse(l) do
      {l, _} -> offset(l)
      _ -> @default_offset
    end
  end
  def offset(o) when is_integer(o), do: o
  def offset(_), do: @default_offset

  @spec games(User.t(), integer, integer) :: [Game.t()]
  def games(%{battletag: battletag}, limit, offset) do
    DeckTracker.games([
      {"player_btag", battletag},
      {"limit", limit},
      {"offset", offset},
      :latest
    ])
  end

  def games(_), do: []

  def handle_params(params, _uri, socket) do
    limit =
      case Util.to_int(params["limit"], nil) do
        nil -> @default_limit
        l -> Enum.min([l, 100])
      end

    offset =
      case Util.to_int(params["offset"], nil) do
        nil -> @default_offset
        o -> o
      end

    {
      :noreply,
      socket
      |> assign(:limit, limit)
      |> assign(:offset, offset)
    }
  end

  def handle_event("toggle_cards", params, socket) do
    Components.ExpandableDecklist.toggle_cards(params)

    {
      :noreply,
      socket
    }
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}
end
