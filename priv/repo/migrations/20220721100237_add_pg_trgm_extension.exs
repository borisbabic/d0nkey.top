defmodule Backend.Repo.Migrations.AddPgTrgmExtension do
  use Ecto.Migration

  def change do
    execute "create extension if not exists pg_trgm;"
  end
end
