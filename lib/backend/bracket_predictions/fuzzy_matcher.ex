defmodule Backend.BracketPredictions.FuzzyMatcher do
  @moduledoc """
  Fuzzy string matching utility to match Battlefy participant/stage names with local names.
  Uses case normalization, Battletag stripping, substring heuristic, and Jaro distance.
  """

  @doc """
  Given a list of Battlefy external names and a list of local names,
  computes suggested mappings and ranked alternatives.

  Returns a map:
  %{
    battlefy_name => %{
      suggested_local_name: String.t() | nil,
      confidence: float(),
      matches: [%{local_name: String.t(), score: float()}]
    }
  }
  """
  @spec suggest_mappings([String.t()], [String.t()]) :: map()
  def suggest_mappings(battlefy_names, local_names) do
    battlefy_names
    |> Enum.uniq()
    |> Enum.reject(&is_nil/1)
    |> Map.new(fn bf_name ->
      scored =
        local_names
        |> Enum.uniq()
        |> Enum.reject(&is_nil/1)
        |> Enum.map(fn local ->
          score = calculate_similarity(bf_name, local)
          %{local_name: local, score: Float.round(score, 3)}
        end)
        |> Enum.sort_by(& &1.score, :desc)

      top_match = List.first(scored)

      suggested =
        if top_match && top_match.score >= 0.6 do
          top_match.local_name
        else
          nil
        end

      confidence = if top_match, do: top_match.score, else: 0.0

      {
        bf_name,
        %{
          suggested_local_name: suggested,
          confidence: confidence,
          matches: scored
        }
      }
    end)
  end

  @doc """
  Calculates similarity between an external name and a local name on a scale of 0.0 to 1.0.
  """
  @spec calculate_similarity(String.t(), String.t()) :: float()
  def calculate_similarity(nil, _), do: 0.0
  def calculate_similarity(_, nil), do: 0.0

  def calculate_similarity(external, local) do
    ext_clean = clean_name(external)
    loc_clean = clean_name(local)

    cond do
      ext_clean == loc_clean ->
        1.0

      # Stripped battletag (e.g. "XiaoT#1234" vs "XiaoT")
      strip_battletag(ext_clean) == loc_clean ->
        0.98

      # Substring match (e.g. "XiaoT (Liquid)" vs "XiaoT")
      String.contains?(ext_clean, loc_clean) or String.contains?(loc_clean, ext_clean) ->
        0.90

      true ->
        # Jaro distance (built into Elixir standard library)
        String.jaro_distance(ext_clean, loc_clean)
    end
  end

  @doc """
  Resolves an external name to the mapped local name,
  falling back to the raw name if no mapping exists.
  """
  @spec resolve_name(String.t() | nil, map() | nil) :: String.t() | nil
  def resolve_name(nil, _), do: nil
  def resolve_name(name, nil), do: name

  def resolve_name(name, mappings) when is_map(mappings) do
    Map.get(mappings, name) ||
      Map.get(mappings, clean_name(name)) ||
      name
  end

  defp clean_name(str) do
    str
    |> to_string()
    |> String.trim()
    |> String.downcase()
  end

  defp strip_battletag(str) do
    str
    |> String.split("#")
    |> List.first()
  end
end
