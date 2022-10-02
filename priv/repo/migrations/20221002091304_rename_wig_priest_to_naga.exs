defmodule Backend.Repo.Migrations.RenameWigPriestToNaga do
  use Ecto.Migration

  def change do
    execute("UPDATE public.deck SET archetype = 'Naga Priest' WHERE archetype = 'Wig Priest';")
  end
end
