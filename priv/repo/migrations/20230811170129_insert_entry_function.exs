defmodule Backend.Repo.Migrations.InsertEntryFunction do
  use Ecto.Migration

  def change do
    up = """
    create or replace function public.insert_entry ()
    returns  trigger 
    language plpgsql
    as $$
    declare 
    begin 
    insert into public.leaderboards_entry (rank, season_id, account_id, rating, inserted_at)
    values (new.rank, new.season_id, new.account_id, new.rating, new.inserted_at);
    return new;
    end;
    $$;
    """

    down = "DROP FUNCTION public.insert_entry;"
    execute(up, down)
  end
end
