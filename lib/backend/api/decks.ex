defmodule Backend.Api.Decks do
  @moduledoc "Query and serialization layer for the public developer deck feed."

  import Ecto.Query, warn: false

  alias Backend.Hearthstone.Deck
  alias Backend.Repo
  alias Hearthstone.DeckTracker

  @allowed_params ~w(
    cursor format includes_latest_set limit min_games min_winrate opponent_class period
    player_class player_deck_archetype player_deck_excludes player_deck_includes
    player_has_coin rank
  )
  @coin_values ~w(any yes no)
  @default_limit 20
  @maximum_limit 100
  @default_min_games 200
  @minimum_min_games 50
  @maximum_list_size 25
  @maximum_archetype_length 100
  @maximum_integer 2_147_483_647

  @spec latest(map()) :: {:ok, map()} | {:error, term()}
  def latest(params) do
    with :ok <- reject_unknown_params(params),
         {:ok, format} <- format_param(params),
         {:ok, period} <- period_param(params, format),
         {:ok, rank} <- rank_param(params),
         {:ok, limit} <- integer_param(params, "limit", @default_limit, 1, @maximum_limit),
         {:ok, min_games} <-
           integer_param(
             params,
             "min_games",
             @default_min_games,
             @minimum_min_games,
             @maximum_integer
           ),
         {:ok, min_winrate} <- optional_winrate_param(params),
         {:ok, player_has_coin} <- enum_param(params, "player_has_coin", "any", @coin_values),
         {:ok, player_class} <- class_param(params, "player_class", nil),
         {:ok, opponent_class} <- class_param(params, "opponent_class", "any"),
         {:ok, archetypes} <- string_list_param(params, "player_deck_archetype"),
         {:ok, includes} <- integer_list_param(params, "player_deck_includes"),
         {:ok, excludes} <- integer_list_param(params, "player_deck_excludes"),
         {:ok, includes_latest_set} <- latest_set_param(params),
         {:ok, cursor} <- decode_cursor(Map.get(params, "cursor")) do
      filters = %{
        "exclude_bugged_sources" => "yes",
        "format" => format,
        "limit" => limit,
        "min_games" => min_games,
        "opponent_class" => opponent_class,
        "order_by" => "newest_deck",
        "period" => period,
        "player_has_coin" => player_has_coin,
        "rank" => rank
      }

      filters =
        filters
        |> put_optional("min_winrate", min_winrate)
        |> put_optional("player_class", player_class)
        |> put_optional("player_deck_archetype", archetypes)
        |> put_optional("player_deck_includes", includes)
        |> put_optional("player_deck_excludes", excludes)
        |> put_optional("includes_latest_set", includes_latest_set)

      query_filters =
        filters
        |> Map.put("limit", limit + 1)
        |> add_cursor(cursor)

      if DeckTracker.fresh_or_agg_deck_stats(query_filters) == :agg do
        {:ok, build_page(query_filters, filters, limit)}
      else
        {:error, :filters_not_available}
      end
    end
  end

  defp build_page(query_filters, filters, limit) do
    stats = DeckTracker.deck_stats(query_filters)
    has_more = length(stats) > limit
    page_stats = Enum.take(stats, limit)
    decks_by_id = decks_by_id(page_stats)

    decks =
      Enum.flat_map(page_stats, fn stats ->
        case Map.get(decks_by_id, value(stats, :deck_id)) do
          %Deck{} = deck -> [serialize_deck(deck, stats)]
          nil -> []
        end
      end)

    next_cursor =
      if has_more do
        case List.last(decks) do
          %{id: deck_id, created_at: inserted_at} -> encode_cursor(inserted_at, deck_id)
          _ -> nil
        end
      end

    %{
      filters: filters,
      decks: decks,
      pagination: %{limit: limit, next_cursor: next_cursor}
    }
  end

  defp decks_by_id(stats) do
    ids = Enum.map(stats, &value(&1, :deck_id))

    from(deck in Deck, where: deck.id in ^ids)
    |> Repo.all()
    |> Map.new(&{&1.id, &1})
  end

  defp serialize_deck(deck, stats) do
    archetype = Deck.archetype(deck)

    %{
      id: deck.id,
      deckcode: deck.deckcode,
      format: %{id: deck.format, name: Deck.format_name(deck.format)},
      class: Deck.class(deck),
      archetype: archetype && to_string(archetype),
      dust_cost: deck.cost,
      cards: serialize_cards(deck.cards),
      sideboards: serialize_sideboards(deck.sideboards),
      created_at: NaiveDateTime.to_iso8601(deck.inserted_at),
      url: Deck.link(deck),
      stats: %{
        wins: integer_value(stats, :wins),
        losses: integer_value(stats, :losses),
        games: integer_value(stats, :total),
        winrate: value(stats, :winrate),
        average_turns: value(stats, :turns),
        average_duration_seconds: value(stats, :duration),
        climbing_speed: value(stats, :climbing_speed)
      }
    }
  end

  defp serialize_cards(cards) do
    cards
    |> Enum.frequencies()
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(fn {dbf_id, count} -> %{dbf_id: dbf_id, count: count} end)
  end

  defp serialize_sideboards(sideboards) do
    Enum.map(List.wrap(sideboards), fn sideboard ->
      %{dbf_id: sideboard.card, count: sideboard.count, owner_dbf_id: sideboard.sideboard}
    end)
  end

  defp reject_unknown_params(params) do
    case Map.keys(params) -- @allowed_params do
      [] -> :ok
      [parameter | _] -> invalid_parameter(parameter, "is not supported")
    end
  end

  defp format_param(params) do
    case Map.get(params, "format", DeckTracker.default_format(:public)) do
      format when format in [2, "2", "standard", "Standard"] -> {:ok, 2}
      format when format in [1, "1", "wild", "Wild"] -> {:ok, 1}
      _ -> invalid_parameter("format", "must be Standard (2) or Wild (1)")
    end
  end

  defp period_param(params, format) do
    period = Map.get(params, "period") || DeckTracker.default_period(format)

    case DeckTracker.get_period_by_slug(period) do
      %{include_in_deck_filters: true, formats: formats} ->
        if format in List.wrap(formats),
          do: {:ok, period},
          else: invalid_parameter("period", "is not available for this format")

      _ ->
        invalid_parameter("period", "is not available for this format")
    end
  end

  defp rank_param(params) do
    rank = Map.get(params, "rank") || DeckTracker.default_rank(:public)

    case DeckTracker.get_rank_by_slug(rank) do
      %{include_in_deck_filters: true} -> {:ok, rank}
      _ -> invalid_parameter("rank", "is not available")
    end
  end

  defp integer_param(params, key, default, minimum, maximum) do
    value = Map.get(params, key, default)

    with {:ok, integer} <- parse_integer(value),
         true <- integer >= minimum,
         true <- is_nil(maximum) or integer <= maximum do
      {:ok, integer}
    else
      _ -> invalid_parameter(key, integer_range_message(minimum, maximum))
    end
  end

  defp integer_range_message(minimum, maximum), do: "must be an integer between #{minimum} and #{maximum}"

  defp parse_integer(value) when is_integer(value), do: {:ok, value}

  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> {:ok, integer}
      _ -> :error
    end
  end

  defp parse_integer(_), do: :error

  defp optional_winrate_param(params) do
    case Map.get(params, "min_winrate") do
      nil -> {:ok, nil}
      raw -> normalize_winrate(raw)
    end
  end

  defp normalize_winrate(value) when is_integer(value), do: normalize_winrate(value / 1)

  defp normalize_winrate(value) when is_float(value) and value >= 0 and value <= 100 do
    {:ok, if(value > 1, do: value / 100, else: value)}
  end

  defp normalize_winrate(value) when is_binary(value) do
    case Float.parse(value) do
      {number, ""} -> normalize_winrate(number)
      _ -> invalid_parameter("min_winrate", "must be a number between 0 and 100")
    end
  end

  defp normalize_winrate(_),
    do: invalid_parameter("min_winrate", "must be a number between 0 and 100")

  defp enum_param(params, key, default, allowed) do
    value = Map.get(params, key, default)

    if value in allowed,
      do: {:ok, value},
      else: invalid_parameter(key, "must be one of: #{Enum.join(allowed, ", ")}")
  end

  defp class_param(params, key, default) do
    value = Map.get(params, key, default)

    cond do
      value == nil -> {:ok, nil}
      value == "any" -> {:ok, "any"}
      true -> validate_classes(key, List.wrap(value))
    end
  end

  defp validate_classes(key, classes) do
    valid_input? =
      length(classes) in 1..@maximum_list_size and
        Enum.all?(classes, &(is_binary(&1) and String.trim(&1) != ""))

    normalized =
      if valid_input?,
        do: classes |> Enum.map(&(String.trim(&1) |> String.upcase())) |> Enum.uniq(),
        else: []

    if normalized != [] and Enum.all?(normalized, &(&1 in Deck.classes())),
      do: {:ok, normalized},
      else:
        invalid_parameter(
          key,
          "must contain 1 to #{@maximum_list_size} valid Hearthstone class names"
        )
  end

  defp string_list_param(params, key) do
    case Map.get(params, key) do
      nil ->
        {:ok, nil}

      value ->
        values = List.wrap(value)

        if length(values) in 1..@maximum_list_size and
             Enum.all?(values, &valid_archetype_name?/1) do
          normalized = values |> Enum.map(&String.trim/1) |> Enum.uniq()
          {:ok, normalized}
        else
          invalid_parameter(
            key,
            "must contain 1 to #{@maximum_list_size} non-empty archetype names"
          )
        end
    end
  end

  defp integer_list_param(params, key) do
    case Map.get(params, key) do
      nil -> {:ok, nil}
      value -> parse_integer_list(key, List.wrap(value))
    end
  end

  defp valid_archetype_name?(value) when is_binary(value) do
    String.trim(value) != "" and String.length(value) <= @maximum_archetype_length
  end

  defp valid_archetype_name?(_value), do: false

  defp parse_integer_list(key, values) do
    parsed = Enum.map(values, &parse_integer/1)

    if length(values) in 1..@maximum_list_size and
         Enum.all?(parsed, &valid_positive_integer?/1) do
      normalized = parsed |> Enum.map(fn {:ok, integer} -> integer end) |> Enum.uniq()
      {:ok, normalized}
    else
      invalid_parameter(
        key,
        "must contain 1 to #{@maximum_list_size} positive DBF IDs"
      )
    end
  end

  defp latest_set_param(params) do
    case Map.get(params, "includes_latest_set") do
      nil -> {:ok, nil}
      value when value in ["yes", "true", true] -> {:ok, "yes"}
      _ -> invalid_parameter("includes_latest_set", "must be yes or true")
    end
  end

  defp decode_cursor(nil), do: {:ok, nil}
  defp decode_cursor(""), do: {:ok, nil}

  defp decode_cursor(cursor) when is_binary(cursor) and byte_size(cursor) <= 512 do
    with {:ok, json} <- Base.url_decode64(cursor, padding: false),
         {:ok, %{"inserted_at" => inserted_at, "id" => id}} <- Jason.decode(json),
         true <- is_integer(id) and id in 1..@maximum_integer,
         {:ok, timestamp} <- NaiveDateTime.from_iso8601(inserted_at) do
      {:ok, {timestamp, id}}
    else
      _ -> invalid_parameter("cursor", "is invalid")
    end
  end

  defp decode_cursor(_), do: invalid_parameter("cursor", "is invalid")

  defp valid_positive_integer?({:ok, integer}), do: integer in 1..@maximum_integer
  defp valid_positive_integer?(_), do: false

  defp encode_cursor(inserted_at, id) do
    %{"inserted_at" => inserted_at, "id" => id}
    |> Jason.encode!()
    |> Base.url_encode64(padding: false)
  end

  defp add_cursor(filters, nil), do: filters
  defp add_cursor(filters, {inserted_at, id}), do: Map.put(filters, :before_deck, {inserted_at, id})

  defp put_optional(map, _key, nil), do: map
  defp put_optional(map, _key, []), do: map
  defp put_optional(map, key, value), do: Map.put(map, key, value)

  defp invalid_parameter(parameter, message),
    do: {:error, {:invalid_parameter, parameter, message}}

  defp integer_value(stats, key), do: value(stats, key) || 0
  defp value(stats, key), do: Map.get(stats, key) || Map.get(stats, to_string(key))
end
