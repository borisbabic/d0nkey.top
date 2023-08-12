defmodule Backend.Repo.Migrations.CurrentEntryTimestampUpdating do
  use Ecto.Migration

  def change do
    create_function()
    create_trigger()
  end

  def create_function() do
    up = """
    create or replace function public.current_entry_timestamp_update ()
    returns  trigger 
    language plpgsql
    as $$
    declare 
    begin 
      if old is distinct from new then
        new.inserted_at := now();
        return new;
      else
        return new;
      end if;
    end;
    $$;
    """

    down = "DROP FUNCTION public.current_entry_timestamp_update;"
    execute(up, down)
  end

  def create_trigger() do
    up = """
    create trigger d_timestamp_update
      before
    update 
      on
      public.leaderboards_current_entries
      for each row
      execute procedure public.current_entry_timestamp_update();
    """

    down = "DROP trigger d_timestamp_update ON public.leaderboards_current_entries"
    execute(up, down)
  end
end
