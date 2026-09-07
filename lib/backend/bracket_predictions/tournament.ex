defmodule Backend.BracketPredictions.Tournament do
  @moduledoc """
  Represents a prediction tournament.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.UserManager.User
  alias Backend.BracketPredictions.Stage
  alias Backend.BracketPredictions.Match
  alias Backend.BracketPredictions.Entry

  schema "bracket_tournaments" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :battlefy_tournament_id, :string
    field :status, :string, default: "open"
    field :prediction_deadline, :naive_datetime
    field :predict_scores, :boolean, default: false
    field :scoring_strategy, :string, default: "flat"
    field :scoring_config, :map, default: %{}
    field :participant_mappings, :map, default: %{}
    field :allow_multiple_entries, :boolean, default: false

    belongs_to :creator, User
    has_many :stages, Stage, foreign_key: :tournament_id
    has_many :matches, Match, foreign_key: :tournament_id
    has_many :entries, Entry, foreign_key: :tournament_id

    timestamps()
  end

  @doc false
  def changeset(tournament, attrs) do
    tournament
    |> cast(attrs, [
      :name,
      :slug,
      :description,
      :battlefy_tournament_id,
      :status,
      :prediction_deadline,
      :predict_scores,
      :scoring_strategy,
      :scoring_config,
      :participant_mappings,
      :allow_multiple_entries
    ])
    |> validate_required([:name])
    |> maybe_generate_slug()
    |> validate_inclusion(:status, ["draft", "open", "locked", "completed"])
    |> validate_inclusion(:scoring_strategy, ["flat", "round_weighted", "exact_matchup"])
    |> unique_constraint(:slug)
  end

  defp maybe_generate_slug(changeset) do
    case get_field(changeset, :slug) do
      slug when is_binary(slug) and slug != "" ->
        changeset

      _ ->
        case get_field(changeset, :name) do
          name when is_binary(name) and name != "" ->
            base =
              name
              |> String.downcase()
              |> String.replace(~r/[^a-z0-9\s-]/, "")
              |> String.replace(~r/\s+/, "-")
              |> String.trim("-")

            put_change(changeset, :slug, "#{base}-#{:rand.uniform(99_999)}")

          _ ->
            changeset
        end
    end
  end

  @doc "Checks whether the prediction deadline has passed"
  def deadline_passed?(%__MODULE__{prediction_deadline: nil}), do: false

  def deadline_passed?(%__MODULE__{prediction_deadline: deadline}) do
    NaiveDateTime.compare(NaiveDateTime.utc_now(), deadline) != :lt
  end

  def deadline_passed?(_), do: false

  @doc "Checks whether predictions can still be submitted"
  def open_for_predictions?(%__MODULE__{status: "open", prediction_deadline: nil}), do: true

  def open_for_predictions?(%__MODULE__{status: "open", prediction_deadline: deadline}) do
    NaiveDateTime.before?(NaiveDateTime.utc_now(), deadline)
  end

  def open_for_predictions?(_), do: false

  def creator?(%__MODULE__{creator_id: creator_id}, %User{id: user_id}), do: creator_id == user_id
  def creator?(_, _), do: false
  def can_manage?(tournament, user), do: creator?(tournament, user) or User.can_access?(user, :super)

  def contestants(%{matches: matches}) do
    matches
    |> Enum.flat_map(fn m ->
      [m.top_name, m.bottom_name]
    end)
    |> Enum.reject(&(is_nil(&1) or &1 == "TBD"))
    |> Enum.uniq()
  end
end
