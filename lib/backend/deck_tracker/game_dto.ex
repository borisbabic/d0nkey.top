defmodule Hearthstone.DeckTracker.GameDto do
  @moduledoc "DTO to handle deck trackerisms"
  use TypedStruct
  alias __MODULE__
  alias Hearthstone.DeckTracker.PlayerDto
  alias Hearthstone.DeckTracker
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
      player: map["player"] |> PlayerDto.from_raw_map(map["format"]),
      opponent:
        (map["opponent"] || map["opposing_player"]) |> PlayerDto.from_raw_map(map["format"]),
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
    |> add_card_info(dto)
  end

  def add_card_info(
        attrs,
        %{
          player: %{
            cards_in_hand_after_mulligan: [_ | _] = mull,
            cards_drawn_from_initial_deck: [_ | _] = drawn
          }
        }
      ) do
    case create_card_tally_ecto_attrs(mull, drawn) do
      {:ok, tallies} ->
        Map.put(attrs, "card_tallies", add_deck_id(tallies, attrs["player_deck"]))

      {:error, _error} ->
        Map.put(attrs, "raw_player_card_stats", create_raw_stats_attrs(mull, drawn))
    end
  end

  def add_card_info(attrs, _dto), do: attrs

  defp add_deck_id(tallies, %{id: deck_id}) when is_integer(deck_id) do
    Enum.map(tallies, &Map.put(&1, :deck_id, deck_id))
  end

  defp add_deck_id(tallies, _deck), do: tallies

  def create_card_tally_ecto_attrs(mull, drawn, game_id) do
    with {:ok, attrs} <- create_card_tally_ecto_attrs(mull, drawn) do
      {:ok, Enum.map(attrs, &Map.put(&1, :game_id, game_id))}
    end
  end

  def create_card_tally_ecto_attrs(mull, drawn) do
    Enum.reduce((mull || []) ++ (drawn || []), {:ok, []}, &to_tally_attrs_reducer/2)
  end

  def to_tally_attrs_reducer(_mull_or_drawn, {:error, error}), do: {:error, error}

  def to_tally_attrs_reducer(mull_or_drawn, {:ok, acc}) do
    with {:ok, dbf_id} <- dbf_id(mull_or_drawn) do
      attrs = to_tally_attrs(dbf_id, mull_or_drawn)
      {:ok, [attrs | acc]}
    end
  end

  defp to_tally_attrs(id, %{turn: turn}) do
    %{
      card_id: id,
      drawn: true,
      mulligan: false,
      turn: turn,
      kept: false
    }
  end

  defp to_tally_attrs(id, %{kept: kept}) do
    %{
      card_id: id,
      drawn: true,
      mulligan: true,
      turn: 0,
      kept: kept
    }
  end

  defp create_raw_stats_attrs(mull, drawn) do
    %{
      "cards_drawn_from_initial_deck" => drawn,
      "cards_in_hand_after_mulligan" => mull
    }
  end

  defp dbf_id(%{card_dbf_id: id}) when is_integer(id), do: {:ok, DeckTracker.tally_card_id(id)}

  defp dbf_id(%{card_id: card_id}) do
    case Backend.HearthstoneJson.get_dbf_by_card_id(card_id) do
      id when is_integer(id) -> {:ok, DeckTracker.tally_card_id(id)}
      _ -> {:error, :could_not_get_dbf_id}
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
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

  # FIRESTONE STARTED SENDING INTEGERS
  def region(1), do: :AM
  def region(2), do: :EU
  def region(3), do: :AP
  def region(4), do: :CN
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
  alias Hearthstone.DeckTracker.CardDrawnDto
  alias Hearthstone.DeckTracker.CardMulliganDto
  alias Backend.Hearthstone.Deck

  typedstruct do
    field :battletag, String.t()
    field :rank, String.t()
    field :legend_rank, String.t()
    field :deckcode, String.t()
    field :cards_in_hand_after_mulligan, Map.t() | nil
    field :cards_drawn_from_initial_deck, Map.t() | nil
    field :class, String.t()
  end

  @spec from_raw_map(Map.t(), String.t() | integer()) :: PlayerDto.t()
  def from_raw_map(map, deck_format_override) do
    new_map =
      with new_format when is_integer(new_format) <- Util.to_int_or_orig(deck_format_override),
           code when is_binary(code) <- map["deckcode"],
           {:ok, %{format: old_format, cards: cards, hero: hero, sideboards: sideboards}}
           when old_format != new_format <- Deck.decode(code) do
        new_deckcode = Deck.deckcode(cards, hero, new_format, sideboards)
        Map.put(map, "deckcode", new_deckcode)
      else
        _ -> map
      end

    from_raw_map(new_map)
  end

  def from_raw_map(map) when is_map(map) do
    mull_raw = map["cards_in_hand_after_mulligan"] || map["cardsInHandAfterMulligan"]

    drawn_raw = map["cards_drawn_from_initial_deck"] || map["cardsDrawnFromInitialDeck"]

    %__MODULE__{
      battletag: map["battletag"] || map["battleTag"],
      rank: map["rank"],
      legend_rank: map["legend_rank"] || map["legendRank"],
      cards_in_hand_after_mulligan: CardMulliganDto.from_raw_list(mull_raw),
      cards_drawn_from_initial_deck: CardDrawnDto.from_raw_list(drawn_raw),
      class: map["class"],
      deckcode: map["deckcode"]
    }
  end

  def from_raw_map(_), do: %{} |> from_raw_map()
end

defmodule Hearthstone.DeckTracker.CardMulliganDto do
  @moduledoc "handles card entry info"
  use TypedStruct

  @derive Jason.Encoder

  typedstruct do
    field :card_id, integer()
    field :card_dbf_id, integer() | nil
    field :kept, boolean()
  end

  def from_raw_list(list) when is_list(list), do: Enum.map(list, &from_raw_map/1)
  def from_raw_list(_), do: nil
  def from_raw_map(nil), do: nil

  def from_raw_map(map) do
    %__MODULE__{
      card_id: map["card_id"] || map["cardId"],
      card_dbf_id: map["card_dbf_id"] || map["cardDbfId"],
      kept: map["kept"]
    }
  end
end

defmodule Hearthstone.DeckTracker.CardDrawnDto do
  @moduledoc "Holds info about a card that was drawn"
  use TypedStruct

  @derive Jason.Encoder

  typedstruct do
    field :card_id, integer()
    field :card_dbf_id, integer() | nil
    field :turn, integer()
  end

  def from_raw_list(list) when is_list(list), do: Enum.map(list, &from_raw_map/1)
  def from_raw_list(_), do: nil
  def from_raw_map(nil), do: nil

  def from_raw_map(map) do
    %__MODULE__{
      card_id: map["card_id"] || map["cardId"],
      card_dbf_id: map["card_dbf_id"] || map["cardDbfId"],
      turn: map["turn"]
    }
  end
end
