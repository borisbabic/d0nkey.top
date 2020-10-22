defmodule Backend.Repo.Migrations.AddMtPlayerNationality do
  use Ecto.Migration

  def change do
    create table(:mt_player_nationality) do
      add :mt_battletag_full, :string
      add :tour_stop, :string
      add :nationality, :string
      add :twitch, :string
      add :actual_battletag_full, :string
      timestamps()
    end

    create(
      unique_index(:mt_player_nationality, [:mt_battletag_full, :tour_stop],
        name: :mt_battletag_full_tour_stop
      )
    )
  end
end
