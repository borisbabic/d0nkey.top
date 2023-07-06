defmodule Hearthstone.DeckTracker.GameDto do
  @moduledoc "DTO to handle deck trackerisms"
  use TypedStruct
  alias __MODULE__
  alias Hearthstone.DeckTracker.PlayerDto
  alias Backend.Hearthstone.Deck
  require Logger

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
    field :replay_url, String.t()
    field :source, String.t()
    field :source_version, String.t()
    field :player_has_coin, boolean()
    field :created_by, Backend.Api.ApiUser.t()
  end

  @spec from_raw_map(Map.t(), ApiUser.t()) :: GameDto.t()
  def from_raw_map(map = %{"GameId" => _}, created_by),
    do: map |> to_snake() |> from_raw_map(created_by)

  def from_raw_map(map = %{"gameId" => _}, created_by),
    do: map |> to_snake() |> from_raw_map(created_by)

  def from_raw_map(map = %{}, created_by) do
    %GameDto{
      player: map["player"] |> PlayerDto.from_raw_map(),
      opponent: (map["opponent"] || map["opposing_player"]) |> PlayerDto.from_raw_map(),
      game_id: map["game_id"],
      game_type: map["game_type"],
      format: map["format"],
      result: map["result"],
      replay_url: map["replay_url"],
      region: map["region"],
      duration: map["duration"],
      player_has_coin: player_has_coin(map),
      turns: map["turns"],
      source: map["source"],
      source_version: map["source_version"],
      created_by: created_by
    }
  end

  def from_raw_map(_, created_by), do: %{} |> from_raw_map(created_by)

  defp player_has_coin(%{"coin" => coin}), do: coin
  defp player_has_coin(%{"player_has_coin" => coin}), do: coin
  defp player_has_coin(_), do: nil

  defp to_snake(map), do: Recase.Enumerable.convert_keys(map, &Recase.to_snake/1)

  def to_ecto_attrs(dto = %GameDto{}, deckcode_handler, source_handler) do
    %{
      "player_btag" => dto.player.battletag,
      "player_rank" => dto.player.rank,
      "player_legend_rank" => dto.player.legend_rank,
      "player_deck" => deckcode_handler.(dto.player.deckcode) |> Util.or_nil(),
      "player_class" => Deck.normalize_class_name(dto.player.class),
      "opponent_btag" => dto.opponent.battletag,
      "opponent_rank" => dto.opponent.rank,
      "opponent_legend_rank" => dto.opponent.legend_rank,
      "opponent_deck" => deckcode_handler.(dto.opponent.deckcode) |> Util.or_nil(),
      "opponent_class" => Deck.normalize_class_name(dto.opponent.class),
      "game_id" => dto.game_id,
      "game_type" => dto.game_type,
      "format" => dto.format,
      "status" => status(dto),
      "region" => region(dto.region),
      "turns" => dto.turns,
      "duration" => dto.duration,
      "replay_url" => dto.replay_url,
      "player_has_coin" => dto.player_has_coin,
      "source" => source_handler.(dto.source, dto.source_version) |> Util.or_nil(),
      "created_by" => dto.created_by
    }
    |> add_raw_stats_ecto_attrs(dto)
  end

  def add_raw_stats_ecto_attrs(
        attrs,
        %{
          player: %{
            cards_in_hand_after_mulligan: [_ | _] = mull,
            cards_drawn_from_initial_deck: [_ | _] = drawn
          }
        }
      ) do
    attrs
    |> Map.put("raw_player_card_stats", %{
      "cards_drawn_from_initial_deck" => drawn,
      "cards_in_hand_after_mulligan" => mull
    })
  end

  def add_raw_stats_ecto_attrs(attrs, _dto), do: attrs

  def status(dto) do
    case dto.result do
      "WIN" ->
        :win

      "WON" ->
        :win

      "LOSS" ->
        :loss

      "LOST" ->
        :loss

      "TIED" ->
        :draw

      "TIE" ->
        :draw

      "DRAW" ->
        :draw

      nil ->
        :in_progress

      other ->
        Logger.warn("Unknown status: #{other} for game #{dto.game_id}")
        :unknown
    end
  end

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
    field :cards_in_hand_after_mulligan, Map.t() | nil
    field :cards_drawn_from_initial_deck, Map.t() | nil
    field :class, String.t()
  end

  @spec from_raw_map(Map.t()) :: PlayerDto.t()
  def from_raw_map(map) when is_map(map) do
    %PlayerDto{
      battletag: map["battletag"] || map["battleTag"],
      rank: map["rank"],
      legend_rank: map["legend_rank"] || map["legendRank"],
      cards_in_hand_after_mulligan:
        map["cards_in_hand_after_mulligan"] || map["cardsInHandAfterMulligan"],
      cards_drawn_from_initial_deck:
        map["cards_drawn_from_initial_deck"] || map["cardsDrawnFromInitialDeck"],
      class: map["class"],
      deckcode: map["deckcode"]
    }
  end

  def from_raw_map(_), do: %{} |> from_raw_map()
end
