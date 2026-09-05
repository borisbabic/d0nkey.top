defmodule Backend.BracketPredictions.DAG do
  @moduledoc """
  Pure DAG evaluation engine for bracket prediction tournaments.

  Handles:
  - Topological evaluation of match contestants based on seeds, winners, and losers.
  - Propagation of predicted winners and losers across matches and stages.
  - Cascade invalidation/pruning of downstream picks when an upstream pick changes.
  """

  alias Backend.BracketPredictions.Match

  @type match_node :: %{
          match: Match.t(),
          predicted_top: String.t() | nil,
          predicted_bottom: String.t() | nil,
          picked_winner: String.t() | nil,
          predicted_top_score: integer() | nil,
          predicted_bottom_score: integer() | nil,
          valid?: boolean()
        }

  @doc """
  Evaluates all matches given a list of matches and a map of picks.
  Picks can be:
    - %{match_identifier => "Winner Name"}
    - %{match_identifier => %{winner: "Winner Name", top_score: 3, bottom_score: 1}}
    - %{match_identifier => %{"winner" => "Winner Name", "top_score" => 3, "bottom_score" => 1}}

  Returns an ordered list of evaluated `match_node` maps.
  """
  @spec evaluate_matches([Match.t()], map()) :: [match_node()]
  def evaluate_matches(matches, picks \\ %{}) do
    sorted_matches = sort_matches_topologically(matches)

    {evaluated_list, _acc_map} =
      Enum.reduce(sorted_matches, {[], %{}}, fn match, {acc_list, evaluated_map} ->
        node = evaluate_match(match, evaluated_map, picks)
        new_map = Map.put(evaluated_map, match.match_identifier, node)
        {[node | acc_list], new_map}
      end)

    Enum.reverse(evaluated_list)
  end

  @doc """
  Applies a pick to a match and re-evaluates the entire tree,
  automatically pruning any downstream picks that have become invalid.

  Returns a cleaned map of valid picks: `%{match_identifier => pick_data}`.
  """
  @spec apply_pick([Match.t()], map(), String.t(), String.t(), map() | nil) :: map()
  def apply_pick(matches, current_picks, match_identifier, chosen_winner, scores \\ nil) do
    pick_entry =
      case scores do
        %{top_score: ts, bottom_score: bs} ->
          %{winner: chosen_winner, top_score: ts, bottom_score: bs}

        %{"top_score" => ts, "bottom_score" => bs} ->
          %{winner: chosen_winner, top_score: ts, bottom_score: bs}

        _ ->
          chosen_winner
      end

    updated_picks = Map.put(current_picks, match_identifier, pick_entry)
    evaluated_nodes = evaluate_matches(matches, updated_picks)

    # Filter updated_picks to only retain those that remain valid
    Enum.reduce(evaluated_nodes, %{}, fn node, valid_acc ->
      if node.picked_winner && node.valid? do
        match_id = node.match.match_identifier
        original_pick = Map.get(updated_picks, match_id)

        case original_pick do
          %{} = map ->
            clean_map = %{
              winner: node.picked_winner,
              top_score: Map.get(map, :top_score) || Map.get(map, "top_score"),
              bottom_score: Map.get(map, :bottom_score) || Map.get(map, "bottom_score")
            }

            Map.put(valid_acc, match_id, clean_map)

          _ ->
            Map.put(valid_acc, match_id, node.picked_winner)
        end
      else
        valid_acc
      end
    end)
  end

  # Evaluates a single match given previously evaluated upstream matches
  defp evaluate_match(match, evaluated_map, picks) do
    pred_top = resolve_participant(match.top_source_type, match.top_source_identifier, match.top_name, evaluated_map)

    pred_bottom =
      resolve_participant(match.bottom_source_type, match.bottom_source_identifier, match.bottom_name, evaluated_map)

    pick_raw = Map.get(picks, match.match_identifier)
    {picked_name, top_score, bottom_score} = extract_pick(pick_raw)

    valid_winner =
      cond do
        is_nil(picked_name) or picked_name == "" ->
          nil

        picked_name == pred_top or picked_name == pred_bottom ->
          picked_name

        true ->
          nil
      end

    %{
      match: match,
      predicted_top: pred_top,
      predicted_bottom: pred_bottom,
      picked_winner: valid_winner,
      predicted_top_score: top_score,
      predicted_bottom_score: bottom_score,
      valid?: !is_nil(valid_winner)
    }
  end

  defp extract_pick(nil), do: {nil, nil, nil}
  defp extract_pick(name) when is_binary(name), do: {name, nil, nil}

  defp extract_pick(%{winner: w} = map) do
    {w, Map.get(map, :top_score), Map.get(map, :bottom_score)}
  end

  defp extract_pick(%{"winner" => w} = map) do
    {w, Map.get(map, "top_score"), Map.get(map, "bottom_score")}
  end

  defp extract_pick(_), do: {nil, nil, nil}

  # Resolves a contestant from its source configuration
  defp resolve_participant("seed", _identifier, seed_name, _evaluated_map) do
    seed_name
  end

  defp resolve_participant("winner_of", source_match_id, _seed_name, evaluated_map) do
    case Map.get(evaluated_map, source_match_id) do
      %{picked_winner: winner} when is_binary(winner) and winner != "" ->
        winner

      # If no pick yet, fall back to actual winner if match is already complete
      %{match: %{is_complete: true, actual_winner_name: winner}} when is_binary(winner) and winner != "" ->
        winner

      _ ->
        nil
    end
  end

  defp resolve_participant("loser_of", source_match_id, _seed_name, evaluated_map) do
    case Map.get(evaluated_map, source_match_id) do
      %{picked_winner: winner, predicted_top: top, predicted_bottom: bottom}
      when is_binary(winner) and winner != "" and not is_nil(top) and not is_nil(bottom) ->
        if winner == top, do: bottom, else: top

      %{match: %{is_complete: true, actual_winner_name: winner, top_name: top, bottom_name: bottom}}
      when is_binary(winner) and winner != "" and not is_nil(top) and not is_nil(bottom) ->
        if winner == top, do: bottom, else: top

      _ ->
        nil
    end
  end

  defp resolve_participant("stage_advancement", identifier, seed_name, evaluated_map) do
    clean_id =
      identifier
      |> to_string()
      |> String.replace(~r/^stage_advancement:/, "")

    cond do
      String.starts_with?(clean_id, "winner_of:") ->
        source_id = String.replace_prefix(clean_id, "winner_of:", "")
        resolve_participant("winner_of", source_id, seed_name, evaluated_map)

      String.starts_with?(clean_id, "loser_of:") ->
        source_id = String.replace_prefix(clean_id, "loser_of:", "")
        resolve_participant("loser_of", source_id, seed_name, evaluated_map)

      true ->
        resolve_participant("winner_of", clean_id, seed_name, evaluated_map)
    end
  end

  defp resolve_participant(_type, _identifier, seed_name, _evaluated_map), do: seed_name

  @doc """
  Sorts matches in topological dependency order.
  Seed matches come first, followed by downstream matches.
  """
  def sort_matches_topologically(matches) do
    Enum.sort_by(matches, fn m ->
      round_weight = (m.round_number || 1) * 100
      order_weight = m.match_order || 0
      round_weight + order_weight
    end)
  end
end
