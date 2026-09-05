defmodule Backend.BracketPredictions.Stage do
  @moduledoc """
  Represents a tournament stage (e.g. GSL Double Elim Groups, Single Elim Playoffs).
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.BracketPredictions.Tournament
  alias Backend.BracketPredictions.Match

  schema "bracket_stages" do
    field :name, :string
    field :sequence, :integer, default: 1
    field :stage_type, :string
    field :config, :map, default: %{}

    belongs_to :tournament, Tournament
    has_many :matches, Match, foreign_key: :stage_id

    timestamps()
  end

  @valid_types ["double_elimination_groups", "double_elimination", "single_elimination"]

  @doc false
  def changeset(stage, attrs) do
    stage
    |> cast(attrs, [:name, :sequence, :stage_type, :config, :tournament_id])
    |> validate_required([:name, :stage_type, :tournament_id])
    |> validate_inclusion(:stage_type, @valid_types)
    |> foreign_key_constraint(:tournament_id)
  end

  def skip_grand_finals?(%__MODULE__{config: %{"skip_grand_finals" => val}}), do: !!val
  def skip_grand_finals?(%__MODULE__{config: %{skip_grand_finals: val}}), do: !!val
  def skip_grand_finals?(_), do: false

  def has_third_place_match?(%__MODULE__{config: %{"has_third_place_match" => val}}), do: !!val
  def has_third_place_match?(%__MODULE__{config: %{has_third_place_match: val}}), do: !!val
  def has_third_place_match?(_), do: false

  def group_count(%__MODULE__{config: %{"group_count" => count}}) when is_integer(count), do: count
  def group_count(%__MODULE__{config: %{group_count: count}}) when is_integer(count), do: count
  def group_count(_), do: 1

  def battlefy_stage_id_for_group(%__MODULE__{config: config}, group_name) when is_map(config) do
    group_map = Map.get(config, "group_battlefy_stage_ids") || Map.get(config, :group_battlefy_stage_ids) || %{}
    Map.get(group_map, group_name) || Map.get(config, "battlefy_stage_id") || Map.get(config, :battlefy_stage_id)
  end

  def battlefy_stage_id_for_group(_, _), do: nil
end
