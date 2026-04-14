defmodule Backend.Repo.Migrations.AddKantaTranslationsTable do
  use Ecto.Migration

  def up do
    # Prefix is needed if you are using multitenancy with i.e. triplex
    Kanta.Migration.up(version: 4)
  end

  # We specify `version: 1` because we want to rollback all the way down including the first migration.
  def down do
    # Prefix is needed if you are using multitenancy with i.e. triplex
    Kanta.Migration.down(version: 1)
  end
end
