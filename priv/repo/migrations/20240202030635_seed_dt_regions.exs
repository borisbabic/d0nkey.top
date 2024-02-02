defmodule Backend.Repo.Migrations.SeedDtRegions do
  use Ecto.Migration

  def up do
    execute("""
    INSERT INTO public.dt_regions 
      (code, display, auto_aggregate, inserted_at, updated_at) 
    VALUES 
      ('AM', 'Americas', true, now(), now()), 
      ('AP', 'Asia-Pacific', false, now(), now()), 
      ('EU', 'Europe', true, now(), now());
    """)
  end

  def down do
    execute("""
    DELETE FROM public.dt_regions WHERE code IN ('AM', 'AP', 'EU')
    """)
  end
end
