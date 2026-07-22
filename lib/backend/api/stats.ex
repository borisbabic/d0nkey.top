defmodule Backend.Api.Stats do
  @moduledoc "Query and serialization layer for the developer stats API."

  alias Backend.Hearthstone.CardBag
  alias Backend.Hearthstone.Deck
  alias Hearthstone.DeckTracker
  alias Hearthstone.DeckTracker.ArchetypeBag

  @archetype_catalog_params ~w(format)
  @meta_params ~w(format period rank opponent_class min_games player_has_coin sort_by)
  @archetype_params ~w(format period rank opponent_class player_has_coin min_mull_count min_drawn_count sort_by sort_direction)
  @meta_sort_fields ~w(winrate total turns duration climbing_speed)
  @card_sort_fields ~w(card mull_impact mull_count drawn_impact drawn_count kept_impact kept_count not_drawn_impact not_drawn_count)
  @sort_directions ~w(asc desc)
  @coin_values ~w(any yes no)
  @maximum_class_filters 25
  @maximum_archetype_length 100
  @maximum_integer 2_147_483_647

  @default_min_games 1000

  @spec archetypes(map()) :: {:ok, map()} | {:error, term()}
  def archetypes(params) do
    with :ok <- reject_unknown_params(params, @archetype_catalog_params),
         {:ok, formats} <- catalog_formats(Map.get(params, "format")) do
      {:ok, %{formats: Enum.map(formats, &serialize_archetype_catalog/1)}}
    end
  end

  @spec meta(map()) :: {:ok, map()} | {:error, term()}
  def meta(params) do
    with :ok <- reject_unknown_params(params, @meta_params),
         {:ok, criteria} <- common_criteria(params, allow_multiple_classes: true),
         {:ok, min_games} <- integer_param(params, "min_games", @default_min_games, min: 0),
         {:ok, sort_by} <- enum_param(params, "sort_by", "winrate", @meta_sort_fields),
         criteria = Map.put(criteria, "sort_by", sort_by),
         :ok <- ensure_aggregated(criteria) do
      stats = DeckTracker.archetype_stats(criteria)
      total = Enum.reduce(stats, 0, &(&2 + integer_value(&1, :total)))

      archetypes =
        stats
        |> Enum.filter(&(integer_value(&1, :total) >= min_games))
        |> Enum.map(&serialize_archetype(&1, total))

      {:ok,
       %{
         filters: Map.put(criteria, "min_games", min_games),
         total_games: total,
         archetypes: archetypes
       }}
    end
  end

  @spec archetype(String.t(), map()) :: {:ok, map()} | {:error, term()}
  def archetype(archetype, params) when is_binary(archetype) do
    with {:ok, archetype} <- validate_archetype_name(archetype),
         :ok <- reject_unknown_params(params, @archetype_params, ["archetype"]),
         {:ok, criteria} <- common_criteria(params),
         {:ok, min_mull_count} <- integer_param(params, "min_mull_count", 0, min: 0),
         {:ok, min_drawn_count} <- integer_param(params, "min_drawn_count", 0, min: 0),
         {:ok, sort_by} <- enum_param(params, "sort_by", "mull_impact", @card_sort_fields),
         {:ok, sort_direction} <- enum_param(params, "sort_direction", "desc", @sort_directions),
         criteria = Map.put(criteria, "archetype", archetype),
         :ok <- ensure_aggregated(criteria),
         overall when is_map(overall) <- DeckTracker.card_stats(criteria) do
      card_stats = value(overall, :card_stats) || []

      cards =
        card_stats
        |> DeckTracker.merge_card_stats()
        |> Enum.filter(fn stats ->
          integer_value(stats, :mull_total) >= min_mull_count and
            integer_value(stats, :drawn_total) >= min_drawn_count
        end)
        |> Enum.map(&serialize_card_stats/1)
        |> sort_cards(sort_by, sort_direction)

      matchups =
        {"archetype", archetype}
        |> DeckTracker.detailed_stats(matchup_criteria(criteria))
        |> Enum.map(&serialize_matchup/1)

      {:ok,
       %{
         archetype: archetype,
         filters:
           criteria
           |> Map.put("min_mull_count", min_mull_count)
           |> Map.put("min_drawn_count", min_drawn_count)
           |> Map.put("sort_by", sort_by)
           |> Map.put("sort_direction", sort_direction),
         stats: serialize_summary(overall),
         matchups: matchups,
         cards: cards
       }}
    else
      {:error, _reason} = error -> error
      _ -> {:error, :archetype_not_found}
    end
  end

  def archetype(_, _), do: {:error, :archetype_not_found}

  defp common_criteria(params, opts \\ []) do
    with {:ok, format} <- format_param(params),
         {:ok, period} <- period_param(params, format),
         {:ok, rank} <- rank_param(params),
         {:ok, opponent_class} <- opponent_class_param(params, opts),
         {:ok, player_has_coin} <- enum_param(params, "player_has_coin", "any", @coin_values) do
      criteria = %{
        "exclude_bugged_sources" => "true",
        "format" => format,
        "opponent_class" => opponent_class,
        "period" => period,
        "player_has_coin" => player_has_coin,
        "rank" => rank
      }

      {:ok, criteria}
    end
  end

  defp catalog_formats(nil), do: {:ok, [2, 1]}
  defp catalog_formats("all"), do: {:ok, [2, 1]}
  defp catalog_formats(format) when format in [2, "2", "standard", "Standard"], do: {:ok, [2]}
  defp catalog_formats(format) when format in [1, "1", "wild", "Wild"], do: {:ok, [1]}

  defp catalog_formats(_format),
    do: invalid_parameter("format", "must be Standard (2) or Wild (1)")

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

  defp ensure_aggregated(criteria) do
    case DeckTracker.fresh_or_agg_archetype_stats(criteria) do
      :agg -> :ok
      :fresh -> {:error, :filters_not_available}
    end
  end

  defp matchup_criteria(criteria) do
    criteria = Map.delete(criteria, "archetype")

    criteria =
      if Map.get(criteria, "opponent_class") == "any" do
        Map.delete(criteria, "opponent_class")
      else
        criteria
      end

    Enum.to_list(criteria)
  end

  defp reject_unknown_params(params, allowed, ignored \\ []) do
    unknown = (Map.keys(params) -- allowed) -- ignored

    case unknown do
      [] -> :ok
      [parameter | _] -> invalid_parameter(parameter, "is not supported")
    end
  end

  defp integer_param(params, key, default, opts) do
    value = Map.get(params, key, default)
    minimum = Keyword.get(opts, :min, 0)
    maximum = Keyword.get(opts, :max, @maximum_integer)

    with {:ok, integer} <- parse_integer(value),
         true <- integer >= minimum and integer <= maximum do
      {:ok, integer}
    else
      _ -> invalid_parameter(key, "must be an integer between #{minimum} and #{maximum}")
    end
  end

  defp parse_integer(value) when is_integer(value), do: {:ok, value}

  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> {:ok, integer}
      _ -> :error
    end
  end

  defp parse_integer(_), do: :error

  defp enum_param(params, key, default, allowed) do
    value = Map.get(params, key, default)

    if value in allowed do
      {:ok, value}
    else
      invalid_parameter(key, "must be one of: #{Enum.join(allowed, ", ")}")
    end
  end

  defp opponent_class_param(params, opts) do
    raw_classes = params |> Map.get("opponent_class", "any") |> List.wrap()
    classes = normalize_classes(raw_classes)
    allowed = ["any" | Deck.classes()]
    multiple_allowed? = Keyword.get(opts, :allow_multiple_classes, false)
    valid_count? = length(classes) in 1..@maximum_class_filters
    valid_combination? = classes == ["any"] or "any" not in classes

    if valid_count? and valid_combination? and (multiple_allowed? or length(classes) == 1) and
         Enum.all?(classes, &(&1 in allowed)) do
      {:ok, if(length(classes) == 1, do: hd(classes), else: classes)}
    else
      invalid_parameter("opponent_class", "must contain valid class names")
    end
  end

  defp normalize_classes(classes) do
    if Enum.all?(classes, &is_binary/1) do
      classes
      |> Enum.map(&normalize_class/1)
      |> Enum.uniq()
    else
      []
    end
  end

  defp normalize_class(class) do
    class = String.trim(class)
    if String.downcase(class) == "any", do: "any", else: String.upcase(class)
  end

  defp validate_archetype_name(archetype) do
    archetype = String.trim(archetype)

    if archetype != "" and String.length(archetype) <= @maximum_archetype_length,
      do: {:ok, archetype},
      else:
        invalid_parameter(
          "archetype",
          "must be a non-empty string up to #{@maximum_archetype_length} characters"
        )
  end

  defp invalid_parameter(parameter, message) do
    {:error, {:invalid_parameter, parameter, message}}
  end

  defp serialize_archetype(stats, total_games) do
    games = integer_value(stats, :total)

    %{
      archetype: value(stats, :archetype),
      wins: integer_value(stats, :wins),
      losses: integer_value(stats, :losses),
      games: games,
      winrate: value(stats, :winrate),
      popularity: safe_div(games, total_games),
      average_turns: value(stats, :turns),
      average_duration_seconds: value(stats, :duration),
      climbing_speed: value(stats, :climbing_speed)
    }
  end

  defp serialize_archetype_catalog(format) do
    archetypes =
      format
      |> ArchetypeBag.get_archetypes()
      |> Enum.map(&to_string/1)
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.map(fn archetype ->
        %{
          name: archetype,
          class: Deck.extract_class(archetype),
          stats_path: "/api/v1/archetypes/#{URI.encode(archetype)}?format=#{format}"
        }
      end)

    %{
      id: format,
      slug: if(format == 2, do: "standard", else: "wild"),
      name: Deck.format_name(format),
      archetypes: archetypes
    }
  end

  defp serialize_summary(stats) do
    %{
      wins: integer_value(stats, :wins),
      losses: integer_value(stats, :losses),
      games: integer_value(stats, :total),
      winrate: value(stats, :winrate)
    }
  end

  defp serialize_matchup(stats) do
    %{
      opponent_class: value(stats, :opponent_class),
      wins: integer_value(stats, :wins),
      losses: integer_value(stats, :losses),
      games: integer_value(stats, :total),
      winrate: value(stats, :winrate)
    }
  end

  defp serialize_card_stats(stats) do
    dbf_id = value(stats, :card_id)
    card = CardBag.card(dbf_id)

    %{
      dbf_id: dbf_id,
      card_id: card && card.card_id,
      name: card && card.name,
      mulligan: sample(stats, :mull),
      drawn: sample(stats, :drawn),
      not_drawn: sample(stats, :not_drawn),
      kept: sample(stats, :kept),
      tossed: sample(stats, :tossed)
    }
  end

  defp sample(stats, prefix) do
    {total_key, impact_key} = sample_keys(prefix)

    %{
      games: integer_value(stats, total_key),
      impact: value(stats, impact_key) || 0.0
    }
  end

  defp sample_keys(:mull), do: {:mull_total, :mull_impact}
  defp sample_keys(:drawn), do: {:drawn_total, :drawn_impact}
  defp sample_keys(:not_drawn), do: {:not_drawn_total, :not_drawn_impact}
  defp sample_keys(:kept), do: {:kept_total, :kept_impact}
  defp sample_keys(:tossed), do: {:tossed_total, :tossed_impact}

  defp sort_cards(cards, "card", direction) do
    Enum.sort_by(cards, &(&1.name || ""), sort_direction(direction))
  end

  defp sort_cards(cards, sort_by, direction) do
    {sample_key, value_key} = card_sort_path(sort_by)

    Enum.sort_by(cards, &get_in(&1, [sample_key, value_key]), sort_direction(direction))
  end

  defp card_sort_path("mull_impact"), do: {:mulligan, :impact}
  defp card_sort_path("mull_count"), do: {:mulligan, :games}
  defp card_sort_path("drawn_impact"), do: {:drawn, :impact}
  defp card_sort_path("drawn_count"), do: {:drawn, :games}
  defp card_sort_path("kept_impact"), do: {:kept, :impact}
  defp card_sort_path("kept_count"), do: {:kept, :games}
  defp card_sort_path("not_drawn_impact"), do: {:not_drawn, :impact}
  defp card_sort_path("not_drawn_count"), do: {:not_drawn, :games}

  defp sort_direction("asc"), do: :asc
  defp sort_direction(_), do: :desc

  defp integer_value(stats, key), do: value(stats, key) || 0

  defp value(stats, key), do: Map.get(stats, key) || Map.get(stats, to_string(key))

  defp safe_div(_, 0), do: 0.0
  defp safe_div(value, total), do: value / total
end
