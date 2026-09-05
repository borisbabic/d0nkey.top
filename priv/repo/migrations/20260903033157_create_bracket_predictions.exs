defmodule Backend.Repo.Migrations.CreateBracketPredictions do
  use Ecto.Migration

  def change do
    create table(:bracket_tournaments) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      add :creator_id, references(:users, on_delete: :nilify_all)
      add :battlefy_tournament_id, :string
      add :status, :string, default: "open", null: false
      add :prediction_deadline, :naive_datetime
      add :predict_scores, :boolean, default: false, null: false
      add :scoring_strategy, :string, default: "flat", null: false
      add :scoring_config, :map, default: %{}
      add :participant_mappings, :map, default: %{}
      add :allow_multiple_entries, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:bracket_tournaments, [:slug])
    create index(:bracket_tournaments, [:creator_id])
    create index(:bracket_tournaments, [:status])

    create table(:bracket_stages) do
      add :tournament_id, references(:bracket_tournaments, on_delete: :delete_all), null: false
      add :sequence, :integer, default: 1, null: false
      add :name, :string, null: false
      add :stage_type, :string, null: false
      add :config, :map, default: %{}

      timestamps()
    end

    create index(:bracket_stages, [:tournament_id])
    create index(:bracket_stages, [:tournament_id, :sequence])

    create table(:bracket_matches) do
      add :tournament_id, references(:bracket_tournaments, on_delete: :delete_all), null: false
      add :stage_id, references(:bracket_stages, on_delete: :delete_all), null: false
      add :group_name, :string
      add :round_number, :integer, default: 1, null: false
      add :round_name, :string, null: false
      add :match_identifier, :string, null: false
      add :match_order, :integer, default: 0, null: false
      add :top_source_type, :string, default: "seed", null: false
      add :top_source_identifier, :string
      add :bottom_source_type, :string, default: "seed", null: false
      add :bottom_source_identifier, :string
      add :top_name, :string
      add :bottom_name, :string
      add :top_score, :integer
      add :bottom_score, :integer
      add :actual_winner_name, :string
      add :is_complete, :boolean, default: false, null: false
      add :battlefy_match_id, :string

      timestamps()
    end

    create index(:bracket_matches, [:tournament_id])
    create index(:bracket_matches, [:stage_id])
    create unique_index(:bracket_matches, [:tournament_id, :match_identifier])

    create table(:bracket_entries) do
      add :tournament_id, references(:bracket_tournaments, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :nilify_all)
      add :name, :string, null: false
      add :total_score, :integer, default: 0, null: false
      add :rank, :integer
      add :submitted_at, :naive_datetime

      timestamps()
    end

    create index(:bracket_entries, [:tournament_id])
    create index(:bracket_entries, [:user_id])

    create unique_index(:bracket_entries, [:tournament_id, :user_id],
             name: :bracket_entries_tournament_user_index
           )

    create table(:bracket_picks) do
      add :entry_id, references(:bracket_entries, on_delete: :delete_all), null: false
      add :match_id, references(:bracket_matches, on_delete: :delete_all), null: false
      add :picked_winner_name, :string, null: false
      add :predicted_top_name, :string
      add :predicted_bottom_name, :string
      add :predicted_top_score, :integer
      add :predicted_bottom_score, :integer
      add :is_correct, :boolean
      add :exact_score_correct, :boolean
      add :points_awarded, :integer, default: 0, null: false

      timestamps()
    end

    create index(:bracket_picks, [:entry_id])
    create index(:bracket_picks, [:match_id])
    create unique_index(:bracket_picks, [:entry_id, :match_id])
  end
end
