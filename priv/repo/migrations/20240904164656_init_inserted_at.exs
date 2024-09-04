defmodule Backend.Repo.Migrations.InitInsertedAt do
  use Ecto.Migration

  def up do
    sql =
      "UPDATE public.deck_sheet_listings SET inserted_at = to_timestamp(id), updated_at = to_timestamp(id)"

    execute(sql)
  end

  def down do
  end
end
