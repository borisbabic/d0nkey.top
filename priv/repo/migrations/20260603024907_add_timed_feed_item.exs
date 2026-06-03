defmodule Backend.Repo.Migrations.AddTimedFeedItem do
  use Ecto.Migration

  def change do
    alter table(:feed_items) do
      add :time_window, :boolean, default: false
      add :start_time, :naive_datetime, default: nil
      add :end_time, :naive_datetime, default: nil
    end
  end
end
