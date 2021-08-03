defmodule Hearthstone.DeckTracker.GameDto do
  @moduledoc "DTO to handle deck trackerisms"
  use TypedStruct
  alias __MODULE__
  alias Hearthstone.DeckTracker.PlayerDto

  typedstruct do
    field :player, PlayerDto.t()
    field :opponent, PlayerDto.t()
    field :game_id, String.t()
    field :game_type, integer()
    field :format, integer()
    field :result, String.t()
    field :region, String.t()
    field :duration, integer()
    field :turns, integer()
    field :created_by, Backend.Api.ApiUser.t()
  end

  @spec from_raw_map(Map.t(), ApiUser.t()) :: PlayerDto.t()
  def from_raw_map(map = %{}, created_by) do
    %GameDto{
      player: map["player"] |> PlayerDto.from_raw_map(),
      opponent: map["opponent"] |> PlayerDto.from_raw_map(),
      game_id: map["game_id"],
      game_type: map["game_type"],
      format: map["format"],
      result: map["result"],
      region: map["region"],
      duration: map["duration"],
      turns: map["turns"],
      created_by: created_by
    }
  end

  def from_raw_map(_, created_by), do: %{} |> from_raw_map(created_by)

  def to_ecto_attrs(dto = %GameDto{}, deckcode_handler) do
    %{
      "player_btag" => dto.player.battletag,
      "player_rank" => dto.player.rank,
      "player_legend_rank" => dto.player.legend_rank,
      "player_deck" => deckcode_handler.(dto.player.deckcode) |> Util.or_nil(),
      "opponent_btag" => dto.opponent.battletag,
      "opponent_rank" => dto.opponent.rank,
      "opponent_legend_rank" => dto.opponent.legend_rank,
      "opponent_deck" => deckcode_handler.(dto.opponent.deckcode) |> Util.or_nil(),
      "game_id" => dto.game_id,
      "game_type" => dto.game_type,
      "format" => dto.format,
      "status" => status(dto.result),
      "region" => region(dto.region),
      "turns" => dto.turns,
      "duration" => dto.duration,
      "created_by" => dto.created_by
    }
  end

  def status("WON"), do: :win
  def status("LOST"), do: :loss
  def status("TIED"), do: :draw
  def status(nil), do: :in_progress
  def status(_), do: :unknown

  def region("REGION_" <> region), do: region(region)
  def region("EU"), do: :EU
  def region("CN"), do: :CN
  def region("KR"), do: :AP
  def region("AP"), do: :AP
  def region("US"), do: :AM
  def region("NA"), do: :AM
  def region(_), do: :unknown
end

defmodule Hearthstone.DeckTracker.PlayerDto do
  @moduledoc "handles player info"
  use TypedStruct
  alias __MODULE__

  typedstruct do
    field :battletag, String.t()
    field :rank, String.t()
    field :legend_rank, String.t()
    field :deckcode, String.t()
  end

  @spec from_raw_map(Map.t()) :: PlayerDto.t()
  def from_raw_map(map) when is_map(map) do
    %PlayerDto{
      battletag: map["battletag"],
      rank: map["rank"],
      legend_rank: map["legend_rank"],
      deckcode: map["deckcode"]
    }
  end

  def from_raw_map(_), do: %{} |> from_raw_map()
end