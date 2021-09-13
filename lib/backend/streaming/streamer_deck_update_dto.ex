defmodule Backend.Streaming.StreamerDeckInfoDto do
  @moduledoc "Additional info collected from deck trackers to update streamer decks"
  use TypedStruct
  alias Hearthstone.DeckTracker.Game
  alias Hearthstone.Enums.GameType
  alias Backend.HSReplay.Streaming

  typedstruct enforce: false do
    field :rank, integer
    field :legend_rank, integer
    field :game_type, integer
    field :result, atom() | nil
  end

  def create(game = %Game{}),
    do: create(game.player_rank, game.player_legend_rank, GameType.as_bnet(game), game.status)

  def create(streaming = %Streaming{}) do
    %{rank: rank, legend_rank: legend_rank} = Backend.Streaming.ranks(streaming)
    create(rank, legend_rank, streaming.game_type)
  end

  def create(rank, legend_rank, game_type, result \\ nil) do
    %__MODULE__{
      rank: rank,
      legend_rank: legend_rank,
      game_type: game_type,
      result: result
    }
  end
end
