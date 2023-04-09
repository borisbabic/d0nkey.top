defmodule Backend.Repo.Migrations.SelfReportSource do
  use Ecto.Migration

  def change do
    execute " INSERT INTO public.dt_sources (id, source, version, inserted_at, updated_at) VALUES (0, 'Self Report', 0, NOW(), NOW()) ON CONFLICT(id) DO NOTHING;"
  end
end
